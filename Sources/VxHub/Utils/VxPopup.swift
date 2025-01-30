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
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle"
            case .error: return "xmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .info: return "info.circle"
            case .debug: return "magnifyingglass.circle"
            }
        }
    }
    
    // MARK: - Properties
    private let padding: CGFloat = 12
    private let animationDuration: TimeInterval = 0.3
    private var isShowingPopup = false
    private var popupQueue: [PopupItem] = []
    private var cancellables = Set<AnyCancellable>()
    private let buttonWidth: CGFloat = 60
    private let iconWidth: CGFloat = 20
    private let horizontalSpacing: CGFloat = 8
    private let basePopupHeight: CGFloat = 48
    
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

    private func calculateMessageLabelSize(
        for message: String,
        with font: UIFont,
        completion: @escaping @Sendable (CGSize) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let screenWidth = UIScreen.main.bounds.width
            let availableWidth = screenWidth - (padding * 4) - buttonWidth - iconWidth - (horizontalSpacing * 2)
            
            let constraintRect = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
            let boundingBox = message.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            
            let labelHeight = ceil(boundingBox.height)
            let totalHeight = max(basePopupHeight, labelHeight + (padding * 2))
            let size = CGSize(width: availableWidth, height: totalHeight)
            completion(size)
        }
    }

    private func displayPopup(_ item: PopupItem) {
        let messageFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        calculateMessageLabelSize(for: item.message, with: messageFont) { [weak self] messageLabelSize in
            guard let self = self else { return }
            debugPrint("size is ", messageLabelSize)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let contentView = UIView()
                contentView.backgroundColor = item.type.backgroundColor
                contentView.layer.cornerRadius = 8
                contentView.clipsToBounds = true
                contentView.translatesAutoresizingMaskIntoConstraints = false
                
                let mainHorizontalStackView = UIStackView()
                mainHorizontalStackView.axis = .horizontal
                mainHorizontalStackView.spacing = 8
                mainHorizontalStackView.alignment = .fill
                mainHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
                
                let iconVerticalStackView = UIStackView()
                iconVerticalStackView.axis = .vertical
                iconVerticalStackView.spacing = 0
                iconVerticalStackView.alignment = .fill
                iconVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
                
                let iconImageView = UIImageView()
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.tintColor = item.type.textColor
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
                iconImageView.image = UIImage(systemName: item.type.iconName, withConfiguration: configuration)
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                let messageVerticalStackView = UIStackView()
                messageVerticalStackView.axis = .vertical
                messageVerticalStackView.spacing = 0
                messageVerticalStackView.alignment = .fill
                messageVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
                
                let messageLabel = UILabel()
                messageLabel.text = item.message
                messageLabel.textColor = item.type.textColor
                messageLabel.numberOfLines = 0
                messageLabel.font = messageFont
                messageLabel.textAlignment = .left
                messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                //            messageLabel.setContentHuggingPriority(.required, for: .vertical)
                
                let buttonVerticalStackView = UIStackView()
                buttonVerticalStackView.axis = .vertical
                buttonVerticalStackView.spacing = 0
                buttonVerticalStackView.alignment = .fill
                
                let button: UIButton?
                if let buttonText = item.buttonText {
                    button = UIButton(type: .system)
                    button?.setTitle(buttonText, for: .normal)
                    button?.setTitleColor(item.type.textColor, for: .normal)
                    button?.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
                    button?.titleLabel?.minimumScaleFactor = 0.6
                    button?.titleLabel?.adjustsFontSizeToFitWidth = true
                    button?.layer.borderWidth = 2
                    button?.layer.borderColor = item.type.textColor.cgColor
                    button?.layer.cornerRadius = 4
                    button?.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
                    
                    if let action = item.buttonAction {
                        button?.addAction(UIAction { [weak self] _ in
                            action()
                            self?.dismissCurrentPopup(contentView)
                        }, for: .touchUpInside)
                    }
                } else {
                    button = nil
                }
                
                contentView.addSubview(mainHorizontalStackView)
                mainHorizontalStackView.addArrangedSubview(iconVerticalStackView)
                
                iconVerticalStackView.addArrangedSubview(iconImageView)
                iconVerticalStackView.addArrangedSubview(UIView.flexibleSpacer())
//                
                mainHorizontalStackView.addArrangedSubview(messageVerticalStackView)
                messageVerticalStackView.addArrangedSubview(messageLabel)
                messageVerticalStackView.addArrangedSubview(UIView.flexibleSpacer())
                
                mainHorizontalStackView.addArrangedSubview(buttonVerticalStackView)
                if let button {
                    buttonVerticalStackView.addArrangedSubview(button)
                    buttonVerticalStackView.addArrangedSubview(UIView.flexibleSpacer())
                }
                
                guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                window.addSubview(contentView)
                
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: self.padding),
                    contentView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -self.padding),
                    contentView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: self.padding),
                    contentView.heightAnchor.constraint(equalToConstant: messageLabelSize.height),
                    
                    mainHorizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: self.padding),
                    mainHorizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.padding),
                    mainHorizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.padding),
                    mainHorizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -self.padding),
                    
                    iconVerticalStackView.widthAnchor.constraint(equalToConstant: self.iconWidth),
                    iconImageView.heightAnchor.constraint(equalToConstant: self.iconWidth),
                    
                    buttonVerticalStackView.widthAnchor.constraint(equalToConstant: self.buttonWidth)
                ])
                
                if let button {
                    NSLayoutConstraint.activate([
                        button.heightAnchor.constraint(equalToConstant: 24)
                    ])
                }
                
                contentView.alpha = 0
                contentView.transform = CGAffineTransform(translationX: 0, y: -100)
                
                UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut) {
                    contentView.alpha = 1
                    contentView.transform = .identity
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + item.duration) {
                    self.dismissCurrentPopup(contentView)
                }
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
