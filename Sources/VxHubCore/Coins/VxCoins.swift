import Foundation

/// The outcome of `VxHub.shared.spendCoins`. Coins live on the VxHub backend
/// (`device_balances`); this is the only way an app spends them.
public enum VxSpendCoinsResult: Sendable, Equatable {
    /// Coins were deducted; `balance` is what is left.
    case spent(balance: Int)
    /// A premium device is never charged.
    case premium(balance: Int)
    /// The device cannot pay. Nothing was deducted.
    case insufficient(balance: Int)
    /// Network or server failure. Nothing is known to have been deducted; the
    /// app decides whether to let the action through (local-first) or not.
    case failed(String?)

    /// The balance the backend reported, when it reported one.
    public var balance: Int? {
        switch self {
        case .spent(let balance), .premium(let balance), .insufficient(let balance): return balance
        case .failed: return nil
        }
    }
}

/// 200 body of POST device/balance/spend.
struct VxSpendCoinsResponse: Decodable {
    let status: String
    let balance: Int
    let premium: Bool
}

/// 403 body of POST device/balance/spend.
struct VxSpendCoinsFailure: Decodable {
    let errorCode: String?
    let balance: Int?
}

enum VxSpendCoinsParser {
    /// Maps a raw response to a result. Kept free of networking so it can be tested.
    static func parse(statusCode: Int, data: Data) -> VxSpendCoinsResult {
        let decoder = JSONDecoder()
        if (200...299).contains(statusCode) {
            guard let body = try? decoder.decode(VxSpendCoinsResponse.self, from: data) else {
                return .failed("Unreadable spend response")
            }
            return body.premium || body.status == "premium" ? .premium(balance: body.balance) : .spent(balance: body.balance)
        }
        if statusCode == 403,
           let body = try? decoder.decode(VxSpendCoinsFailure.self, from: data),
           body.errorCode == "INSUFFICIENT_CREDITS" {
            return .insufficient(balance: body.balance ?? 0)
        }
        return .failed("Spend failed (\(statusCode))")
    }
}
