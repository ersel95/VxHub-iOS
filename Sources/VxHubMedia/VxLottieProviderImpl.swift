#if canImport(UIKit)
//
//  VxLottieProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import UIKit
import VxHubCore
import Lottie

public final class VxLottieProviderImpl: VxAnimationProvider, @unchecked Sendable {

    private var activeAnimations: [Int: LottieAnimationView] = [:]
    private var completionHandlers: [Int: () -> Void] = [:]
    private let lock = NSLock()

    public init() {}

    // MARK: - VxAnimationProvider

    public func createAndPlayAnimation(
        name: String,
        in parentView: UIView,
        tag: Int,
        removeOnFinish: Bool,
        loopAnimation: Bool,
        animationSpeed: CGFloat,
        contentMode: UIView.ContentMode,
        completion: (@Sendable () -> Void)?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Remove existing animation with same tag if present
            if parentView.subviews.contains(where: { $0.tag == tag }) {
                if let view = parentView.subviews.first(where: { $0.tag == tag }) {
                    view.removeFromSuperview()
                    self.lock.lock()
                    self.activeAnimations.removeValue(forKey: tag)
                    self.completionHandlers.removeValue(forKey: tag)
                    self.lock.unlock()
                }
            }

            let animationView = LottieAnimationView()
            animationView.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(animationView)

            NSLayoutConstraint.activate([
                animationView.topAnchor.constraint(equalTo: parentView.topAnchor),
                animationView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                animationView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])

            self.playAnimation(
                name: name,
                view: animationView,
                tag: tag,
                removeOnFinish: removeOnFinish,
                loopEnabled: loopAnimation,
                animationSpeed: animationSpeed,
                contentMode: contentMode,
                completion: completion
            )
        }
    }

    public func stopAnimation(with tag: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let view = self.activeAnimations[tag]
            self.lock.unlock()
            view?.stop()
        }
    }

    public func stopAllAnimations() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let animations = self.activeAnimations
            self.lock.unlock()
            animations.forEach { (_, view) in
                view.stop()
            }
        }
    }

    public func clearAnimation(with tag: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            if let view = self.activeAnimations[tag] {
                self.lock.unlock()
                view.stop()
                view.removeFromSuperview()
                self.removeAnimation(with: tag)
            } else {
                self.lock.unlock()
            }
        }
    }

    public func clearAllAnimations() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let animations = self.activeAnimations
            self.activeAnimations.removeAll()
            self.completionHandlers.removeAll()
            self.lock.unlock()

            animations.forEach { (_, view) in
                view.stop()
                view.removeFromSuperview()
            }
        }
    }

    public func downloadAnimation(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
        VxDownloader().download(from: urlString) { data in
            let fileName = URL(string: urlString ?? "")?.lastPathComponent ?? "animation.json"
            VxFileManager().save(data, type: .thirdPartyDir, fileName: fileName, overwrite: true) { _ in }
        } completion: { _, error in
            if let error = error {
                VxLogger.shared.error("Failed to download animation: \(error.localizedDescription)")
            }
            completion(error)
        }
    }

    // MARK: - Private Helpers

    private func getAnimationPath(for urlString: String) -> URL? {
        let fileName = URL(string: urlString)?.lastPathComponent ?? "animation.json"
        let fileManager = VxFileManager()
        let thirdPartyURL = fileManager.vxHubDirectoryURL(for: .thirdPartyDir).appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: thirdPartyURL.path) {
            return thirdPartyURL
        }

        if let bundlePath = Bundle.main.path(forResource: fileName, ofType: nil) {
            return URL(fileURLWithPath: bundlePath)
        }

        return nil
    }

    private func playAnimation(
        name: String,
        view: LottieAnimationView,
        tag: Int,
        removeOnFinish: Bool,
        loopEnabled: Bool,
        animationSpeed: CGFloat,
        contentMode: UIView.ContentMode,
        completion: (@Sendable () -> Void)?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.lock.lock()
            if let existingView = self.activeAnimations[tag] {
                existingView.stop()
                existingView.removeFromSuperview()
            }
            self.lock.unlock()

            view.tag = tag
            view.loopMode = loopEnabled ? .loop : .playOnce
            view.animationSpeed = animationSpeed
            view.contentMode = contentMode

            self.lock.lock()
            self.activeAnimations[tag] = view
            if let completion = completion {
                self.completionHandlers[tag] = completion
            }
            self.lock.unlock()

            if let animationPath = self.getAnimationPath(for: name) {
                LottieAnimation.loadedFrom(url: animationPath) { lottieAnimation in
                    view.animation = lottieAnimation
                    view.play { [weak self] finished in
                        guard let self = self else { return }
                        if finished {
                            self.lock.lock()
                            let handler = self.completionHandlers[tag]
                            self.lock.unlock()
                            handler?()
                            if removeOnFinish {
                                self.removeAnimation(with: tag)
                            }
                        }
                    }
                }
            } else {
                view.animation = .named(name)
                view.play { [weak self] finished in
                    guard let self = self else { return }
                    if finished {
                        self.lock.lock()
                        let handler = self.completionHandlers[tag]
                        self.lock.unlock()
                        handler?()
                        if removeOnFinish {
                            self.removeAnimation(with: tag)
                        }
                    }
                }
            }
        }
    }

    private func removeAnimation(with tag: Int) {
        lock.lock()
        activeAnimations.removeValue(forKey: tag)
        completionHandlers.removeValue(forKey: tag)
        lock.unlock()
    }
}
#endif
