//
//  File.swift
//  VxHub
//
//  Created by furkan on 6.11.2024.
//

import UIKit
import WebKit

final class VxWebViewer: UIViewController, @unchecked Sendable { //TODO: - look for dispose ways
    
    static let shared = VxWebViewer()
    private var isFullscreen: Bool = false
    
    var webView : WKWebView = {
       let webView = WKWebView()
    return webView
    }()
    
    lazy var closeButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButtonPlaceholderview : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeButtonStack : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.backgroundColor = .gray
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var mainStack : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    private init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL, isFullscreen: Bool = false, showCloseButton: Bool = true) {
        self.isFullscreen = isFullscreen
        self.modalPresentationStyle = isFullscreen ? .fullScreen : .pageSheet
        
        setupUI(showCloseButton: showCloseButton)
        loadUrl(url: url)
    }
    
    
    private func setupUI(showCloseButton: Bool) {
        if showCloseButton || isFullscreen {
            self.closeButtonStack.addArrangedSubview(self.closeButtonPlaceholderview)
            self.closeButtonStack.addArrangedSubview(self.closeButton)
            
            self.mainStack.addArrangedSubview(self.closeButtonStack)
            NSLayoutConstraint.activate([
                self.closeButton.widthAnchor.constraint(equalToConstant: 30),
                self.closeButtonStack.heightAnchor.constraint(equalToConstant: 30),
            ])
        }
        
        self.mainStack.addArrangedSubview(webView)
        self.view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            self.mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func clearWebViewCache(completion: @escaping () -> Void) {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            dataStore.removeData(ofTypes: dataTypes, for: records) {
                completion()
            }
        }
    }

    private func loadUrl(url: URL) {
        clearWebViewCache { [weak self] in
            guard let self = self else { return }
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            self.webView.load(request)
        }
    }

    @objc private func closeTapped() {
        handleDismissal()
    }
    
    private func handleDismissal() {
        if isFullscreen || presentingViewController != nil {
            dismiss(animated: true)
        } else if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func present(url: URL, isFullscreen: Bool = false, showCloseButton: Bool = true) {
        guard let topViewController = UIApplication.shared.topViewController(),
              !(topViewController is VxWebViewer) else {
            return
        }

        let webViewer = VxWebViewer.shared
        webViewer.configure(with: url, isFullscreen: isFullscreen, showCloseButton: showCloseButton)
        if let topViewController = UIApplication.shared.topViewController() {
            topViewController.present(webViewer, animated: true)
        }
    }
}

extension VxWebViewer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleDismissal()
    }
}

