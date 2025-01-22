//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import Foundation
import Reachability

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

internal class VxReachabilityManager {
    // MARK: - Properties
    private let reachability: Reachability?
    private var timer: DispatchSourceTimer?
    private var currentStatus: Reachability.Connection = .unavailable
    private let queue = DispatchQueue(label: "vx.reachability.queue")
    
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
    func startMonitoring(checkInterval: TimeInterval = 1.0) {
        guard let reachability = reachability else { return }
        
        do {
            try reachability.startNotifier()
            setupPeriodicCheck(interval: checkInterval)
        } catch {
            print("VxReachabilityManager: Could not start monitoring: \(error)")
        }
    }
    
    func stopMonitoring() {
        reachability?.stopNotifier()
        timer?.cancel()
        timer = nil
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
    
    private func setupPeriodicCheck(interval: TimeInterval) {
        timer?.cancel()
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: interval)
        
        timer?.setEventHandler { [weak self] in
            self?.checkConnectionStatus()
        }
        
        timer?.resume()
    }
    
    private func checkConnectionStatus() {
        guard let reachability = reachability else { return }
        let newStatus = reachability.connection
        
        if currentStatus != newStatus {
                    VxLogger.shared.log("isConnected: \(isConnected), connectionType: \(newStatus)", level: .debug, type: .info)
            handleReachabilityChange(reachability)
        }
    }
    
    private func handleReachabilityChange(_ reachability: Reachability) {
        let oldStatus = currentStatus
        currentStatus = reachability.connection
        
        let userInfo: [String: Any] = [
            "isConnected": self.isConnected,
            "previousStatus": oldStatus
        ]
        
        self.delegate?.reachabilityStatusChanged(userInfo)
    }
}

