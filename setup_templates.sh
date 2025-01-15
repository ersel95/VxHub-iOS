#!/bin/bash

# Define directories
TEMPLATES_DIR="$HOME/Library/Developer/Xcode/Templates/File Templates"
CUSTOM_DIR="$TEMPLATES_DIR/Custom"
MODULE_TEMPLATE_DIR="$CUSTOM_DIR/Volvox Module.xctemplate"

# Create directories
mkdir -p "$MODULE_TEMPLATE_DIR"

# Create TemplateInfo.plist
cat > "$MODULE_TEMPLATE_DIR/TemplateInfo.plist" << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Kind</key>
    <string>Xcode.IDEFoundation.TextSubstitutionFileTemplateKind</string>
    <key>Description</key>
    <string>Creates a new MVVM-C module with Controller, ViewModel, Coordinator, and RootView.</string>
    <key>Summary</key>
    <string>Creates a new MVVM-C module</string>
    <key>SortOrder</key>
    <string>1</string>
    <key>AllowedTypes</key>
    <array>
        <string>public.swift-source</string>
    </array>
    <key>Platforms</key>
    <array>
        <string>com.apple.platform.iphoneos</string>
    </array>
    <key>DefaultCompletionName</key>
    <string>NewModule</string>
    <key>MainTemplateFile</key>
    <string>___FILEBASENAME___Controller.swift</string>
    <key>Options</key>
    <array>
        <dict>
            <key>Identifier</key>
            <string>productName</string>
            <key>Required</key>
            <true/>
            <key>Name</key>
            <string>Module Name:</string>
            <key>Description</key>
            <string>The name of the module to create</string>
            <key>Type</key>
            <string>text</string>
            <key>NotPersisted</key>
            <true/>
        </dict>
    </array>
</dict>
</plist>
EOL

# Create Controller template
cat > "$MODULE_TEMPLATE_DIR/___FILEBASENAME___Controller.swift" << 'EOL'
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit
import Combine

final class ___VARIABLE_productName___Controller: NiblessViewController {
    // MARK: - Properties
    private let viewModel: ___VARIABLE_productName___ViewModel
    private var rootView: ___VARIABLE_productName___RootView!
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: ___VARIABLE_productName___ViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func loadView() {
        rootView = ___VARIABLE_productName___RootView(viewModel: viewModel)
        view = rootView
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupBindings()
    }
    
    private func setupNavigation() {
        navigationItem.title = "___VARIABLE_productName___"
    }
    
    private func setupBindings() {
        // Setup your Combine bindings here
    }
}
EOL

# Create ViewModel template
cat > "$MODULE_TEMPLATE_DIR/___FILEBASENAME___ViewModel.swift" << 'EOL'
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import Foundation
import Combine

final class ___VARIABLE_productName___ViewModel {
    // MARK: - Properties
    private let coordinator: ___VARIABLE_productName___Coordinator
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - Publishers
    let loadingStateSubject = PassthroughSubject<Bool, Never>()
    
    // MARK: - Initialization
    init(coordinator: ___VARIABLE_productName___Coordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        // Setup initial state
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Setup your Combine bindings here
    }
}
EOL

# Create Coordinator template
cat > "$MODULE_TEMPLATE_DIR/___FILEBASENAME___Coordinator.swift" << 'EOL'
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import Foundation
import UIKit
import Combine

final class ___VARIABLE_productName___Coordinator: Coordinator {
    internal weak var navigationController: UINavigationController?
    private var disposeBag = Set<AnyCancellable>()
    private let appRoot: CurrentValueSubject<Roots, Never>
    
    init(navigationController: UINavigationController?,
         appRoot: CurrentValueSubject<Roots, Never>)
    {
        self.navigationController = navigationController
        self.appRoot = appRoot
    }
    
    func start() {
        let viewModel = ___VARIABLE_productName___ViewModel(coordinator: self)
        let controller = ___VARIABLE_productName___Controller(viewModel: viewModel)
        self.navigationController?.setViewControllers([controller], animated: false)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController?.present(alert, animated: true)
    }
}
EOL

# Create RootView template
cat > "$MODULE_TEMPLATE_DIR/___FILEBASENAME___RootView.swift" << 'EOL'
//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit
import Combine

final class ___VARIABLE_productName___RootView: NiblessView {
    // MARK: - Properties
    private let viewModel: ___VARIABLE_productName___ViewModel
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Initialization
    init(viewModel: ___VARIABLE_productName___ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .systemBackground
        addSubview(containerStackView)
    }
    
    private func setupConstraints() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        // Setup your Combine bindings here
    }
}
EOL

# Set proper permissions
chmod -R 755 "$CUSTOM_DIR"
chmod -R 644 "$MODULE_TEMPLATE_DIR"/*

# Remove old template directories if they exist
rm -rf "$TEMPLATES_DIR/Judgr Module"
rm -rf "$CUSTOM_DIR/Judgr Module.xctemplate"

echo "Xcode templates have been installed successfully!"
echo "Please restart Xcode"
echo "After restart, you can create new modules using File > New > File > Custom > Volvox Module" 