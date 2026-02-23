//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import Foundation
#if canImport(Reachability)
import Reachability
#else
import Network
#endif

public enum VxConnection: String {
    case unavailable, wifi, cellular

    public var description: String {
        switch self {
        case .cellular: return "Cellular"
        case .wifi: return "WiFi"
        case .unavailable: return "No Connection"
        }
    }
}

public protocol VxReachabilityDelegate: AnyObject {
    func reachabilityStatusChanged(_ userInfo: [String: Any])
}

#if canImport(Reachability)
internal class VxReachabilityManager {
    // MARK: - Properties
    private let reachability: Reachability?
    private var currentStatus: Reachability.Connection = .unavailable

    weak var delegate: VxReachabilityDelegate?

    var isConnected: Bool {
        get {
            guard let reachability = reachability else { return false }
            return reachability.connection != .unavailable
        }
    }

    var connectionType: Reachability.Connection {
        get {
            return reachability?.connection ?? .unavailable
        }
    }

    // MARK: - Initialization
    public init() {
        reachability = try? Reachability()
        setupReachability()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Internal Methods
    func startMonitoring() {
        guard let reachability = reachability else { return }

        do {
            try reachability.startNotifier()
        } catch {
            print("VxReachabilityManager: Could not start monitoring: \(error)")
        }
    }

    func stopMonitoring() {
        reachability?.stopNotifier()
    }

    // MARK: - Private Methods
    private func setupReachability() {
        reachability?.whenReachable = { [weak self] reachability in
            self?.handleReachabilityChange(reachability)
        }

        reachability?.whenUnreachable = { [weak self] reachability in
            self?.handleReachabilityChange(reachability)
        }
    }

    private func handleReachabilityChange(_ reachability: Reachability) {
        let oldStatus = currentStatus
        currentStatus = reachability.connection

        VxLogger.shared.log("isConnected: \(isConnected), connectionType: \(currentStatus)", level: .debug, type: .info)

        let userInfo: [String: Any] = [
            "isConnected": self.isConnected,
            "previousStatus": oldStatus
        ]

        self.delegate?.reachabilityStatusChanged(userInfo)
    }
}

#else

// MARK: - NWPathMonitor Fallback
internal class VxReachabilityManager {
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "com.vxhub.reachability")
    private var currentStatus: VxConnection = .unavailable

    weak var delegate: VxReachabilityDelegate?

    var isConnected: Bool {
        return currentStatus != .unavailable
    }

    // MARK: - Initialization
    public init() {
        monitor = NWPathMonitor()
        setupMonitor()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Internal Methods
    func startMonitoring() {
        monitor.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Private Methods
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let oldStatus = self.currentStatus

            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    self.currentStatus = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.currentStatus = .cellular
                } else {
                    self.currentStatus = .wifi // default to wifi for other satisfied paths
                }
            } else {
                self.currentStatus = .unavailable
            }

            VxLogger.shared.log("isConnected: \(self.isConnected), connectionType: \(self.currentStatus)", level: .debug, type: .info)

            let userInfo: [String: Any] = [
                "isConnected": self.isConnected,
                "previousStatus": oldStatus
            ]

            DispatchQueue.main.async {
                self.delegate?.reachabilityStatusChanged(userInfo)
            }
        }
    }
}
#endif
