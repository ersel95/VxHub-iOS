//
//  VxAuthStateStore.swift
//  VxHub
//

import Foundation

/**
 Synchronously readable snapshot of the auth state.

 `VxAuthSession` is an actor, which is right for serializing refreshes but wrong
 for a view that needs `currentUser` while laying out. This mirror holds the
 same values behind a lock so `VxHub.shared.currentUser` stays a plain property,
 and posts a notification so SwiftUI can follow along.
 */
internal final class VxAuthStateStore: @unchecked Sendable {
    static let shared = VxAuthStateStore()

    private let lock = NSLock()
    private var _session: VxUserSession?
    private var _user: VxUser?
    private var _config: VxAuthConfig?

    private init() {}

    var session: VxUserSession? {
        get { lock.withLock { _session } }
        set {
            lock.withLock { _session = newValue }
            notify()
        }
    }

    var user: VxUser? {
        get { lock.withLock { _user } }
        set {
            lock.withLock { _user = newValue }
            notify()
        }
    }

    var config: VxAuthConfig? {
        get { lock.withLock { _config } }
        set {
            lock.withLock { _config = newValue }
            notify()
        }
    }

    private func notify() {
        NotificationCenter.default.post(name: .vxHubAuthStateDidChange, object: nil)
    }
}

public extension Notification.Name {
    /// Posted when the signed-in account, its session or the auth config changes.
    static let vxHubAuthStateDidChange = Notification.Name("vxHubAuthStateDidChange")
}
