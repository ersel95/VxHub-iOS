import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Generic session analytics tracker. Collects screen views and custom events,
/// batches them, and sends to VxHub backend.
internal final class VxSessionTracker: @unchecked Sendable {

    static let shared = VxSessionTracker()

    // MARK: - Session State

    private var sessionId: String = ""
    private var eventIndex: Int = 0
    private var currentScreen: String?
    private var screenEnteredAt: CFAbsoluteTime = 0
    private var pendingEvents: [[String: Any]] = []
    private let queue = DispatchQueue(label: "com.vxhub.session-tracker", qos: .utility)
    private var flushTimer: Timer?
    private var isStarted = false

    private init() {}

    // MARK: - Lifecycle

    func start() {
        guard !isStarted else { return }
        isStarted = true
        beginNewSession()

        #if canImport(UIKit) && os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif

        startFlushTimer()
    }

    // MARK: - Public Tracking API

    func trackScreen(_ name: String) {
        queue.async { [weak self] in
            guard let self else { return }

            // Record duration on previous screen
            if let prevScreen = self.currentScreen {
                let duration = Int((CFAbsoluteTimeGetCurrent() - self.screenEnteredAt) * 1000)
                self.enqueue(eventName: "screen_exit", screenName: prevScreen, properties: nil, durationMs: duration)
            }

            self.currentScreen = name
            self.screenEnteredAt = CFAbsoluteTimeGetCurrent()
            self.enqueue(eventName: "screen_view", screenName: name, properties: nil, durationMs: nil)
        }
    }

    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        queue.async { [weak self] in
            guard let self else { return }
            self.enqueue(eventName: name, screenName: self.currentScreen, properties: properties, durationMs: nil)
        }
    }

    // MARK: - Session Management

    private func beginNewSession() {
        sessionId = UUID().uuidString
        eventIndex = 0
        currentScreen = nil

        let metadata: [String: Any] = [
            "appVersion": VxHub.shared.deviceConfig?.os ?? "",
            "isPremium": VxHub.shared.isPremium,
            "countryCode": VxHub.shared.deviceConfig?.deviceCountry ?? ""
        ]

        sendSessionStart(metadata: metadata)

        enqueue(eventName: "session_start", screenName: nil, properties: metadata, durationMs: nil)
    }

    @objc private func appDidEnterBackground() {
        queue.async { [weak self] in
            guard let self else { return }
            // Record time on last screen
            if let screen = self.currentScreen {
                let duration = Int((CFAbsoluteTimeGetCurrent() - self.screenEnteredAt) * 1000)
                self.enqueue(eventName: "screen_exit", screenName: screen, properties: nil, durationMs: duration)
            }
            self.enqueue(eventName: "session_end", screenName: self.currentScreen, properties: nil, durationMs: nil)
            self.flush()
            self.sendSessionEnd()
        }
    }

    @objc private func appWillEnterForeground() {
        queue.async { [weak self] in
            self?.beginNewSession()
        }
    }

    // MARK: - Event Queue

    private func enqueue(eventName: String, screenName: String?, properties: [String: Any]?, durationMs: Int?) {
        var event: [String: Any] = [
            "eventName": eventName,
            "eventIndex": eventIndex,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let screenName { event["screenName"] = screenName }
        if let properties { event["properties"] = properties }
        if let durationMs { event["durationMs"] = durationMs }

        pendingEvents.append(event)
        eventIndex += 1

        // Auto-flush at 50 events
        if pendingEvents.count >= 50 {
            flush()
        }
    }

    // MARK: - Flush

    private func startFlushTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.flushTimer?.invalidate()
            self?.flushTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                self?.queue.async { self?.flush() }
            }
        }
    }

    private func flush() {
        guard !pendingEvents.isEmpty else { return }
        let events = pendingEvents
        let sid = sessionId
        pendingEvents = []

        let body: [String: Any] = [
            "sessionId": sid,
            "events": events
        ]

        VxNetworkManager().sendSessionEvents(body: body) { error in
            if let error {
                VxLogger.shared.error("Session events flush failed: \(error)")
            }
        }
    }

    // MARK: - Network

    private func sendSessionStart(metadata: [String: Any]) {
        let body: [String: Any] = [
            "sessionId": sessionId,
            "appVersion": metadata["appVersion"] as? String ?? "",
            "isPremium": metadata["isPremium"] as? Bool ?? false,
            "countryCode": metadata["countryCode"] as? String ?? ""
        ]

        VxNetworkManager().sendSessionStart(body: body) { error in
            if let error {
                VxLogger.shared.error("Session start failed: \(error)")
            }
        }
    }

    private func sendSessionEnd() {
        let body: [String: Any] = [
            "sessionId": sessionId,
            "exitScreen": currentScreen ?? ""
        ]

        VxNetworkManager().sendSessionEnd(body: body) { error in
            if let error {
                VxLogger.shared.error("Session end failed: \(error)")
            }
        }
    }
}
