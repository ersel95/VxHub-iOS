//
//  File.swift
//  VxHub
//
//  Created by furkan on 3.01.2025.
//

import UIKit
import Lottie

final internal class VxLottieManager: @unchecked Sendable {
    private var activeAnimations: [Int: LottieAnimationView] = [:]
    private var completionHandlers: [Int: () -> Void] = [:]
    
    private struct Static {
        fileprivate static let lock = NSLock()
        nonisolated(unsafe) fileprivate static var instance: VxLottieManager?
    }

    class var shared: VxLottieManager {
        Static.lock.lock()
        defer { Static.lock.unlock() }
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            let newInstance = VxLottieManager()
            Static.instance = newInstance
            return newInstance
        }
    }
    
    private init() {}
        
    func downloadAnimation(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void) {
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
        
    func playAnimation(
        name: String,
        view: LottieAnimationView,
        tag: Int,
        removeOnFinish: Bool = true,
        loopEnabled: Bool,
        animationSpeed: CGFloat = 1.0,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        completion: (@Sendable () -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let existingView = activeAnimations[tag] {
                existingView.stop()
                existingView.removeFromSuperview()
            }
            
            view.tag = tag
            view.loopMode = loopEnabled ? .loop : .playOnce
            view.animationSpeed = animationSpeed
            view.contentMode = .scaleAspectFit
            activeAnimations[tag] = view
            
            if let completion = completion {
                completionHandlers[tag] = completion
            }
            
            if let animationPath = getAnimationPath(for: name) {
                LottieAnimation.loadedFrom(url: animationPath) { lottieAnimation in
                    view.animation = lottieAnimation
                    view.play { [weak self] finished in
                        guard let self else { return }
                        if finished {
                            self.completionHandlers[tag]?()
                            if removeOnFinish {
                                self.removeAnimation(with: tag)
                            }
                        }
                    }
                }
            } else {
                view.animation = .named(name)
                view.play { [weak self] finished in
                    guard let self else { return }
                    if finished {
                        self.completionHandlers[tag]?()
                        if removeOnFinish {
                            self.removeAnimation(with: tag)
                        }
                    }
                }
            }
        }
    }
    
    func stopAnimation(with tag: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let view = activeAnimations[tag] {
                view.stop()
            }
        }
    }
    
    func stopAllAnimations() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            activeAnimations.forEach { (_, view) in
                view.stop()
            }
        }
    }
    
    func clearAnimation(with tag: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let view = activeAnimations[tag] {
                view.stop()
                view.removeFromSuperview()
                removeAnimation(with: tag)
            }
        }
    }
    
    func clearAllAnimations() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            activeAnimations.forEach { (_, view) in
                view.stop()
                view.removeFromSuperview()
            }
            self.activeAnimations.removeAll()
            self.completionHandlers.removeAll()
            self.dispose()
        }
    }
    
    func getAnimationView(for tag: Int) -> LottieAnimationView? {
        return activeAnimations[tag]
    }
    
    func isAnimationActive(tag: Int) -> Bool {
        return activeAnimations[tag] != nil
    }
    
    var activeAnimationCount: Int {
        return activeAnimations.count
    }
    
    private func removeAnimation(with tag: Int) {
        activeAnimations.removeValue(forKey: tag)
        completionHandlers.removeValue(forKey: tag)
        
        if activeAnimations.isEmpty {
            dispose()
        }
    }
    
    private func dispose() {
        VxLogger.shared.log("LottieManager disposed", level: .debug, type: .success)
        Static.lock.lock()
        VxLottieManager.Static.instance = nil
        Static.lock.unlock()
    }
}

// Extension for convenience methods
extension VxLottieManager {
    func createAndPlayAnimation(
        name: String,
        in parentView: UIView,
        tag: Int,
        removeOnFinish: Bool = true,
        loopAnimation: Bool = false,
        animationSpeed: CGFloat = 1.0,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        completion: (@Sendable () -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if parentView.subviews.contains(where: { $0.tag == tag }) {
                VxLogger.shared.log("Removing animation with tag \(tag) existed in the parent view", level: .info, type: .info)
                
                if let view = parentView.subviews.first(where: { $0.tag == tag }) {
                    view.removeFromSuperview()
                    activeAnimations.removeValue(forKey: tag)
                    completionHandlers.removeValue(forKey: tag)
                    VxLogger.shared.log("Successfully removed animation view with tag \(tag)", level: .info, type: .success)
                } else {
                    VxLogger.shared.log("Animation view with tag \(tag) not found in activeAnimations dictionary", level: .warning, type: .warning)
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
            
            playAnimation(
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
}
