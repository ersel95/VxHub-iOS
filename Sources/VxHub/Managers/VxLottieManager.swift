//
//  File.swift
//  VxHub
//
//  Created by furkan on 3.01.2025.
//

import UIKit
import Lottie

final internal class VxLottieManager: @unchecked Sendable {
    private var activeAnimations: [Int: LottieAnimationView] = [:] {
        didSet {
            debugPrint("Active anims",activeAnimations)
        }
    }
    private var completionHandlers: [Int: () -> Void] = [:]
    
    private struct Static {
        nonisolated(unsafe) fileprivate static var instance: VxLottieManager?
    }
    
    class var shared: VxLottieManager {
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            Static.instance = VxLottieManager()
            return Static.instance!
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
    
    private func getAnimationPath(for name: String) -> URL? {
        let fileManager = VxFileManager()
        let thirdPartyURL = fileManager.vxHubDirectoryURL(for: .thirdPartyDir).appendingPathComponent(name)
        
        if FileManager.default.fileExists(atPath: thirdPartyURL.path) {
            return thirdPartyURL
        }

        if let bundlePath = Bundle.main.path(forResource: name, ofType: "json") {
            return URL(fileURLWithPath: bundlePath)
        }
        
        return nil
    }
        
    func playAnimation(
        name: String,
        view: LottieAnimationView,
        tag: Int,
        loopEnabled: Bool,
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
            activeAnimations[tag] = view
            
            if let completion = completion {
                completionHandlers[tag] = completion
            }
            
            if let animationPath = getAnimationPath(for: name) {
                debugPrint("got path")
                LottieAnimation.loadedFrom(url: animationPath) { lottieAnimation in
                    view.animation = lottieAnimation
                    view.play { [weak self] finished in
                        guard let self else { return }
                        debugPrint("Animation with tag \(tag) finished before self: \(finished)")
                        debugPrint("Animation with tag \(tag) finished: \(finished)")
                        if finished {
                            self.completionHandlers[tag]?()
                            self.removeAnimation(with: tag)
                        }
                    }
                }
            } else {
                view.animation = .named(name)
                view.play { [weak self] finished in
                    guard let self else { return }
                    debugPrint("Animation with tag \(tag) finished before self: \(finished)")
                    debugPrint("Animation with tag \(tag) finished: \(finished)")
                    if finished {
                        self.completionHandlers[tag]?()
                        self.removeAnimation(with: tag)
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
        VxLottieManager.Static.instance = nil
    }
}

// Extension for convenience methods
extension VxLottieManager {
    func createAndPlayAnimation(
        name: String,
        in parentView: UIView,
        tag: Int,
        loopAnimation: Bool = false,
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
                loopEnabled: loopAnimation,
                completion: completion
            )
        }
    }
}
