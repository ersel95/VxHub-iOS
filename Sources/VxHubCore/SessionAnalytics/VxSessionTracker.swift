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
    private var isStarted = false
    private var flushWorkItem: DispatchWorkItem?

    private init() {}

    // MARK: - Lifecycle

    func start() {
        guard !isStarted else { return }
        isStarted = true
        print("[VxSession] ✅ Tracker started")
        beginNewSession()

        #if canImport(UIKit) && os(iOS)
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.appDidEnterBackground),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.appWillEnterForeground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
            print("[VxSession] ✅ Background/Foreground observers registered")
        }
        #endif
    }

    // MARK: - Public Tracking API

    func trackScreen(_ name: String) {
        print("[VxSession] 📱 trackScreen(\"\(name)\")")
        queue.async { [weak self] in
            guard let self else { return }

            if let prevScreen = self.currentScreen {
                let duration = Int((CFAbsoluteTimeGetCurrent() - self.screenEnteredAt) * 1000)
                self.enqueue(eventName: "screen_exit", screenName: prevScreen, properties: nil, durationMs: duration)
            }

            self.currentScreen = name
            self.screenEnteredAt = CFAbsoluteTimeGetCurrent()
            self.enqueue(eventName: "screen_view", screenName: name, properties: nil, durationMs: nil)
            self.scheduleFlush()
        }
    }

    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        print("[VxSession] 🎯 trackEvent(\"\(name)\", properties: \(properties ?? [:]))")
        queue.async { [weak self] in
            guard let self else { return }
            self.enqueue(eventName: name, screenName: self.currentScreen, properties: properties, durationMs: nil)
            self.scheduleFlush()
        }
    }

    // MARK: - Session Management

    private func beginNewSession() {
        sessionId = UUID().uuidString
        eventIndex = 0
        currentScreen = nil
        print("[VxSession] 🆕 New session: \(sessionId.prefix(8))...")

        let metadata: [String: Any] = [
            "appVersion": VxHub.shared.deviceConfig?.os ?? "",
            "isPremium": VxHub.shared.isPremium,
            "countryCode": VxHub.shared.deviceConfig?.deviceCountry ?? ""
        ]

        sendSessionStart(metadata: metadata)
        enqueue(eventName: "session_start", screenName: nil, properties: metadata, durationMs: nil)
    }

    @objc private func appDidEnterBackground() {
        print("[VxSession] ⏸️ App entered background")
        queue.async { [weak self] in
            guard let self else { return }
            if let screen = self.currentScreen {
                let duration = Int((CFAbsoluteTimeGetCurrent() - self.screenEnteredAt) * 1000)
                self.enqueue(eventName: "screen_exit", screenName: screen, properties: nil, durationMs: duration)
            }
            self.enqueue(eventName: "session_end", screenName: self.currentScreen, properties: nil, durationMs: nil)
            self.flushNow()
            self.sendSessionEnd()
        }
    }

    @objc private func appWillEnterForeground() {
        print("[VxSession] ▶️ App entered foreground")
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
        print("[VxSession] 📝 Enqueued: \(eventName) (index: \(eventIndex - 1), pending: \(pendingEvents.count))")
    }

    // MARK: - Flush (debounced 5 seconds, immediate on background)

    private func scheduleFlush() {
        flushWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.flushNow()
        }
        flushWorkItem = work
        queue.asyncAfter(deadline: .now() + 5, execute: work)
        print("[VxSession] ⏱️ Flush scheduled in 5s (pending: \(pendingEvents.count) events)")
    }

    private func flushNow() {
        flushWorkItem?.cancel()
        guard !pendingEvents.isEmpty else {
            print("[VxSession] ⚠️ Flush skipped - no pending events")
            return
        }
        let events = pendingEvents
        let sid = sessionId
        pendingEvents = []

        let eventCount = events.count
        print("[VxSession] 🚀 Flushing \(eventCount) events for session \(sid.prefix(8))...")

        let body: [String: Any] = [
            "sessionId": sid,
            "events": events
        ]

        VxNetworkManager().sendSessionEvents(body: body) { error in
            if let error {
                print("[VxSession] ❌ Events flush FAILED: \(error)")
            } else {
                print("[VxSession] ✅ Events flush SUCCESS (\(eventCount) events)")
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

        print("[VxSession] 🔵 Sending session/start for \(sessionId.prefix(8))...")

        VxNetworkManager().sendSessionStart(body: body) { error in
            if let error {
                print("[VxSession] ❌ Session start FAILED: \(error)")
            } else {
                print("[VxSession] ✅ Session start SUCCESS")
            }
        }
    }

    private func sendSessionEnd() {
        let body: [String: Any] = [
            "sessionId": sessionId,
            "exitScreen": currentScreen ?? ""
        ]

        print("[VxSession] 🔴 Sending session/end for \(sessionId.prefix(8))... (exitScreen: \(currentScreen ?? "none"))")

        VxNetworkManager().sendSessionEnd(body: body) { error in
            if let error {
                print("[VxSession] ❌ Session end FAILED: \(error)")
            } else {
                print("[VxSession] ✅ Session end SUCCESS")
            }
        }
    }
}
