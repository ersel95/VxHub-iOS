//
//  AlertManager.swift
//  Stilyco
//
//  Created by Mr. t. on 27.01.2025.
//

import Foundation
import UIKit

final class VxAlertManager: @unchecked Sendable {
    nonisolated static let shared = VxAlertManager()
    private init() {}

    private func createAlert(
        title: String,
        message: String,
        actions: [UIAlertAction],
        from viewController: UIViewController
    ) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alert.addAction($0) }
           viewController.present(alert, animated: true)
        }

    }

    func present(
        title: String,
        message: String,
        buttonTitle: String,
        from viewController: UIViewController,
        buttonHandler: (@Sendable () -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
                buttonHandler?()
            }
            self.createAlert(title: title, message: message, actions: [action], from: viewController)
        }
    }
}
