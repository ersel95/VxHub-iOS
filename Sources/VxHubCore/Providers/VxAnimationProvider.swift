#if canImport(UIKit)
import UIKit

public protocol VxAnimationProvider: Sendable {
    func createAndPlayAnimation(
        name: String,
        in parentView: UIView,
        tag: Int,
        removeOnFinish: Bool,
        loopAnimation: Bool,
        animationSpeed: CGFloat,
        contentMode: UIView.ContentMode,
        completion: (@Sendable () -> Void)?
    )
    func stopAnimation(with tag: Int)
    func stopAllAnimations()
    func clearAnimation(with tag: Int)
    func clearAllAnimations()
    func downloadAnimation(from urlString: String?, completion: @escaping @Sendable (Error?) -> Void)
}
#endif
