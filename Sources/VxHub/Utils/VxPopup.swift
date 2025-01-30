//
//  VxPopup.swift
//  expenseapp
//
//  Created by Furkan Alioglu on 11.01.2025.
//

import UIKit
import Combine

public final class VxPopup: @unchecked Sendable  {
    // MARK: - Singleton
    public static nonisolated let shared = VxPopup()
    private init() {}
    
    // MARK: - Types
    public enum PopupType: Sendable  {
        case success
        case error
        case warning
        case info
        case debug
        
        var backgroundColor: UIColor {
            switch self {
            case .success: return UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1)
            case .error: return UIColor(red: 220/255, green: 38/255, blue: 38/255, alpha: 1)
            case .warning: return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1)
            case .info: return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1)
            case .debug: return UIColor.black.withAlphaComponent(0.9)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .debug: return .white
            default: return .white
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "✅"
            case .error: return "❌"
            case .warning: return "⚠️"
            case .info: return "ℹ️"
            case .debug: return "🔍"
            }
        }
    }
    
    // MARK: - Properties
    private let padding: CGFloat = 16
    private let animationDuration: TimeInterval = 0.3
    private var isShowingPopup = false
    private var popupQueue: [PopupItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    private struct PopupItem: Sendable {
        let message: String
        let type: PopupType
        let duration: TimeInterval
        let priority: Int
        let buttonText: String?
        let buttonAction: (@Sendable() -> Void)?
    }
    
    // MARK: - Public Methods
    public func show(
        message: String,
        type: PopupType,
        duration: TimeInterval = 3.0,
        priority: Int = 0,
        buttonText: String? = nil,
        buttonAction: (@Sendable() -> Void)? = nil
    ) {
        let item = PopupItem(
            message: message,
            type: type,
            duration: duration,
            priority: priority,
            buttonText: buttonText,
            buttonAction: buttonAction
        )
        
        popupQueue.append(item)
        popupQueue.sort { $0.priority > $1.priority } // Higher priority first
        
        if !isShowingPopup {
            showNextPopup()
        }
    }
    
    // MARK: - Queue Management
    public func clearQueue() {
        popupQueue.removeAll()
        // If there's an active popup, let it finish naturally
    }
    
    // MARK: - Convenience Methods
    public func showError(_ message: String, duration: TimeInterval = 3.0, priority: Int = 1) {
        show(message: message, type: .error, duration: duration, priority: priority)
    }
    
    public func showSuccess(_ message: String, duration: TimeInterval = 3.0, priority: Int = 0) {
        show(message: message, type: .success, duration: duration, priority: priority)
    }
    
    public func showWarning(_ message: String, duration: TimeInterval = 3.0, priority: Int = 0) {
        show(message: message, type: .warning, duration: duration, priority: priority)
    }
    
    public func showInfo(_ message: String, duration: TimeInterval = 3.0, priority: Int = 0) {
        show(message: message, type: .info, duration: duration, priority: priority)
    }
    
    public func showDebug(_ message: String, duration: TimeInterval = 3.0) {
        #if DEBUG
        show(message: message, type: .debug, duration: duration, priority: -1)
        #endif
    }
    
    // MARK: - Private Methods
    private func showNextPopup() {
        guard !popupQueue.isEmpty else {
            isShowingPopup = false
            return
        }
        
        isShowingPopup = true
        let item = popupQueue.removeFirst()
        displayPopup(item)
    }
    
    private func displayPopup(_ item: PopupItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let containerView = UIView()
            containerView.backgroundColor = item.type.backgroundColor
            containerView.layer.cornerRadius = 8
            containerView.clipsToBounds = true
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .center
            
            let messageLabel = UILabel()
            messageLabel.text = "\(item.type.icon) \(item.message)"
            messageLabel.textColor = item.type.textColor
            messageLabel.numberOfLines = 0
            messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
            messageLabel.textAlignment = .left
            
            stackView.addArrangedSubview(messageLabel)
            stackView.addArrangedSubview(UIView.flexibleSpacer())
            
            if let buttonText = item.buttonText {
                let button = UIButton(type: .system)
                button.setTitle(buttonText, for: .normal)
                button.setTitleColor(item.type.textColor, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
                button.layer.borderWidth = 2
                button.layer.borderColor = item.type.textColor.cgColor
                button.layer.cornerRadius = 4
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
                
                if let action = item.buttonAction {
                    button.addAction(UIAction { [weak self] _ in
                        action()
                        // Dismiss the popup immediately after button tap
                        self?.dismissCurrentPopup(containerView)
                    }, for: .touchUpInside)
                }
                
                stackView.addArrangedSubview(button)
            }
            
            containerView.addSubview(stackView)
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            window.addSubview(containerView)
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: self.padding),
                containerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -self.padding),
                containerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: self.padding),
                
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: self.padding),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: self.padding),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -self.padding),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -self.padding)
            ])
            
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(translationX: 0, y: -100)
            
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut) {
                containerView.alpha = 1
                containerView.transform = .identity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + item.duration) {
                self.dismissCurrentPopup(containerView)
            }
        }
    }
    
    private func dismissCurrentPopup(_ containerView: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseIn) {
                containerView.alpha = 0
                containerView.transform = CGAffineTransform(translationX: 0, y: -100)
            } completion: { [weak self] _ in
                containerView.removeFromSuperview()
                self?.showNextPopup()
            }
        }
    }
}
