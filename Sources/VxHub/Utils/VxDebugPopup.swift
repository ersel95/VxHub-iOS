import UIKit

internal final class VxDebugPopup: @unchecked Sendable {
    private let padding: CGFloat = 16
    private let animationDuration: TimeInterval = 0.3
    
    init() {}
    
    func show(message: String, duration: TimeInterval = 3.0) {
        #if DEBUG
        DispatchQueue.main.async {
            debugPrint("furkan gecti 0")
            
            debugPrint("furkan gecti 1")
            let containerView = UIView()
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            containerView.layer.cornerRadius = 8
            containerView.clipsToBounds = true
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.textColor = .white
            messageLabel.numberOfLines = 0
            messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
            messageLabel.textAlignment = .left
            
            containerView.addSubview(messageLabel)
            debugPrint("0")
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            debugPrint("1")
            window.addSubview(containerView)
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: self.padding),
                containerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -self.padding),
                containerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: self.padding),
                
                messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: self.padding),
                messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: self.padding),
                messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -self.padding),
                messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -self.padding)
            ])
                        
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(translationX: 0, y: -100)
            
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut) {
                containerView.alpha = 1
                containerView.transform = .identity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseIn) {
                    containerView.alpha = 0
                    containerView.transform = CGAffineTransform(translationX: 0, y: -100)
                } completion: { _ in
                    containerView.removeFromSuperview()
                }
            }
        }
        #endif
    }
    
    public func showError(_ error: String, duration: TimeInterval = 3.0) {
        show(message: "❌ Error: \(error)", duration: duration)
    }
    
    public func showSuccess(_ message: String, duration: TimeInterval = 3.0) {
        show(message: "✅ \(message)", duration: duration)
    }
    
    public func showWarning(_ message: String, duration: TimeInterval = 3.0) {
        show(message: "⚠️ \(message)", duration: duration)
    }
    
    public func showInfo(_ message: String, duration: TimeInterval = 3.0) {
        show(message: "ℹ️ \(message)", duration: duration)
    }
} 
