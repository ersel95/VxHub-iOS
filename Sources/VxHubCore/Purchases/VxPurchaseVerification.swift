//
//  VxPurchaseVerification.swift
//  VxHub
//
//  The VxHub backend is the only authority on premium. A store purchase is not
//  "done" until device/after-purchase has verified it; a restore is not done until
//  device/restore has. This file holds the result types apps see, the persistent
//  queue that keeps a charged-but-unverified transaction from being lost, and the
//  pure mapping from an HTTP response to a verification outcome.
//

import Foundation

// MARK: - Public results

/// Outcome of `VxHub.shared.purchase(_:resultCompletion:)`.
public enum VxPurchaseResult: Sendable, Equatable {
    /// The backend verified the transaction. `isPremium` is the backend's answer.
    case verified(isPremium: Bool)
    /// The store charged the user but the backend could not be reached or did not
    /// answer usably. The transaction is queued and re-sent on the next start.
    case pendingVerification
    /// The user dismissed the store sheet.
    case cancelled
    /// The store reported an error; nothing was charged.
    case failed(message: String?)
}

/// Outcome of `VxHub.shared.restorePurchases(resultCompletion:)`.
public enum VxRestoreResult: Sendable, Equatable {
    /// The backend re-verified the account. `isPremium` is the backend's answer.
    case restored(isPremium: Bool)
    /// The store has no purchases for this Apple Account.
    case nothingToRestore
    /// The store found purchases but the backend could not verify them right now.
    case pendingVerification
    /// The store restore itself failed.
    case failed(message: String?)
}

// MARK: - Store outcome (provider level)

/// What the store (not the backend) said about a purchase attempt.
public enum VxStorePurchaseOutcome: Sendable {
    case purchased(transactionId: String, productId: String)
    case cancelled
    case failed(message: String?)
}

// MARK: - Backend verification

/// Body returned by device/after-purchase and device/restore.
struct VxPurchaseVerificationResponse: Decodable, Equatable {
    struct Device: Decodable, Equatable {
        let premium_status: Bool
        let balance: Int
    }
    let status: String
    let vid: String
    let verified: Bool?
    let device: Device
}

/// How a verification call ended, independent of networking code so it can be tested.
enum VxVerificationOutcome: Equatable {
    /// Definitive backend answer.
    case verified(isPremium: Bool, balance: Int)
    /// Try again later: transport error, timeout, 408/429/5xx, or an unusable body.
    case retryLater(reason: String)
    /// The endpoint does not exist on this backend (older deployments).
    case unsupported
    /// The backend refused the request (4xx). Kept in the queue until the attempt cap.
    case rejected(statusCode: Int)

    /// - Parameter requireTransactionMatch: for after-purchase. A 200 with
    ///   `"verified": false` means the backend could not find the transaction yet
    ///   (e.g. RevenueCat has not caught up), which must not drop a charged purchase
    ///   from the queue. Restore passes false: there `premium_status` is the answer.
    ///   Older backends that omit `verified` are taken at their word.
    static func classify(statusCode: Int?, data: Data?, transportError: Error?,
                         requireTransactionMatch: Bool = false) -> VxVerificationOutcome {
        if let transportError {
            return .retryLater(reason: "transport: \(transportError.localizedDescription)")
        }
        guard let statusCode else {
            return .retryLater(reason: "no response")
        }
        switch statusCode {
        case 200...299:
            guard let data, !data.isEmpty,
                  let body = try? JSONDecoder().decode(VxPurchaseVerificationResponse.self, from: data) else {
                return .retryLater(reason: "undecodable \(statusCode) body")
            }
            if requireTransactionMatch, body.verified == false {
                return .retryLater(reason: "transaction not verified yet")
            }
            return .verified(isPremium: body.device.premium_status, balance: body.device.balance)
        case 404:
            return .unsupported
        case 408, 429, 500...599:
            return .retryLater(reason: "status \(statusCode)")
        default:
            return .rejected(statusCode: statusCode)
        }
    }
}

// MARK: - Pending transactions

/// A store transaction the backend has not verified yet.
struct VxPendingPurchase: Codable, Equatable, Sendable {
    let transactionId: String
    let productId: String
    let createdAt: Date
    var attempts: Int
}

/// Persists unverified transactions so a timeout, a crash or a killed app can never
/// turn a charged purchase into a silent loss. Written before the first network call.
final class VxPendingPurchaseStore: @unchecked Sendable {

    static let shared = VxPendingPurchaseStore()

    /// Give up after this many failed attempts or this age; by then support has to step in.
    static let maxAttempts = 25
    static let maxAge: TimeInterval = 60 * 60 * 24 * 30

    private let defaults: UserDefaults
    private let key: String
    private let lock = NSLock()
    private var isRetrying = false

    /// Coalesces retry passes: returns false if one is already running.
    func beginRetryPass() -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard !isRetrying else { return false }
        isRetrying = true
        return true
    }

    func endRetryPass() {
        lock.lock(); defer { lock.unlock() }
        isRetrying = false
    }

    init(defaults: UserDefaults = .standard, key: String = "VxHub_pendingPurchaseVerifications") {
        self.defaults = defaults
        self.key = key
    }

    var all: [VxPendingPurchase] {
        lock.lock(); defer { lock.unlock() }
        return load()
    }

    func add(transactionId: String, productId: String, now: Date = Date()) {
        lock.lock(); defer { lock.unlock() }
        var items = load()
        guard !items.contains(where: { $0.transactionId == transactionId }) else { return }
        items.append(VxPendingPurchase(transactionId: transactionId, productId: productId, createdAt: now, attempts: 0))
        save(items)
    }

    func remove(transactionId: String) {
        lock.lock(); defer { lock.unlock() }
        save(load().filter { $0.transactionId != transactionId })
    }

    /// Records a failed attempt. Returns false when the entry was dropped for exceeding
    /// the attempt cap or the maximum age.
    @discardableResult
    func recordFailedAttempt(transactionId: String, now: Date = Date()) -> Bool {
        lock.lock(); defer { lock.unlock() }
        var items = load()
        guard let index = items.firstIndex(where: { $0.transactionId == transactionId }) else { return false }
        items[index].attempts += 1
        let expired = items[index].attempts >= Self.maxAttempts
            || now.timeIntervalSince(items[index].createdAt) > Self.maxAge
        if expired {
            VxLogger.shared.error("Dropping unverified purchase \(transactionId) after \(items[index].attempts) attempts")
            items.remove(at: index)
        }
        save(items)
        return !expired
    }

    private func load() -> [VxPendingPurchase] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([VxPendingPurchase].self, from: data)) ?? []
    }

    private func save(_ items: [VxPendingPurchase]) {
        if items.isEmpty {
            defaults.removeObject(forKey: key)
        } else if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
}
