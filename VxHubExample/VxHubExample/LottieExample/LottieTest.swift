//
//  LottieTest.swift
//  VxHubExample
//
//  Created by furkan on 3.01.2025.
//

import SwiftUI
import UIKit
import VxHub

struct LottieUIKitWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LottieTestViewController {
        return LottieTestViewController()
    }
    
    func updateUIViewController(_ uiViewController: LottieTestViewController, context: Context) {
        // Updates handled in view controller
    }
}

class LottieTestViewController: UIViewController {
    private let containerView = UIView()
    private let loopSwitch = UISwitch()
    private let loopLabel = UILabel()
    private let titleLabel = UILabel()
    private let tagTextField = UITextField()
    
    private lazy var playButton: VxButton = {
        let button = VxButton()
        button.configure(backgroundColor: .systemBlue, foregroundColor: .white, cornerRadius: 8)
        button.setFont(.rounded, size: 16, weight: .medium)
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: VxButton = {
        let button = VxButton()
        button.configure(backgroundColor: .systemRed, foregroundColor: .white, cornerRadius: 8)
        button.setFont(.rounded, size: 16, weight: .medium)
        button.setTitleWithImage("Stop",
                               image: UIImage(systemName: "stop.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage())
        button.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var removeByTagButton: VxButton = {
        let button = VxButton()
        button.configure(backgroundColor: .systemOrange, foregroundColor: .white, cornerRadius: 8)
        button.setFont(.rounded, size: 16, weight: .medium)
        button.setTitleWithImage("Remove Tag",
                               image: UIImage(systemName: "tag.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage())
        button.addTarget(self, action: #selector(removeByTagTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var removeAllButton: VxButton = {
        let button = VxButton()
        button.configure(backgroundColor: .systemPurple, foregroundColor: .white, cornerRadius: 8)
        button.setFont(.rounded, size: 16, weight: .medium)
        button.setTitleWithImage("Remove All", 
                               image: UIImage(systemName: "trash.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage())
        button.addTarget(self, action: #selector(removeAllTapped), for: .touchUpInside)
        return button
    }()
    
    private var isPlaying = false {
        didSet {
            playButton.isLoading = isPlaying
            stopButton.isEnabled = isPlaying
        }
    }
    
    private let animationTag = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel.text = "Lottie Animation Test"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        
        // Animation Container
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // Add content insets to the container
        let contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        containerView.directionalLayoutMargins = contentInsets
        
        // Loop Control
        loopLabel.text = "Loop Animation"
        loopSwitch.addTarget(self, action: #selector(loopSwitchChanged), for: .valueChanged)
        
        // Tag TextField
        tagTextField.placeholder = "Enter animation tag"
        tagTextField.borderStyle = .roundedRect
        tagTextField.keyboardType = .numberPad
        
        // Layout
        [titleLabel, containerView, loopLabel, loopSwitch,
         playButton, stopButton, tagTextField, removeByTagButton, removeAllButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            loopLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            loopLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            loopSwitch.centerYAnchor.constraint(equalTo: loopLabel.centerYAnchor),
            loopSwitch.leadingAnchor.constraint(equalTo: loopLabel.trailingAnchor, constant: 8),
            
            playButton.topAnchor.constraint(equalTo: loopLabel.bottomAnchor, constant: 20),
            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 120),
            playButton.heightAnchor.constraint(equalToConstant: 48),
            
            stopButton.topAnchor.constraint(equalTo: playButton.topAnchor),
            stopButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 120),
            stopButton.heightAnchor.constraint(equalToConstant: 48),
            
            tagTextField.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            tagTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tagTextField.widthAnchor.constraint(equalToConstant: 150),
            tagTextField.heightAnchor.constraint(equalToConstant: 48),
            
            removeByTagButton.topAnchor.constraint(equalTo: tagTextField.topAnchor),
            removeByTagButton.leadingAnchor.constraint(equalTo: tagTextField.trailingAnchor, constant: 8),
            removeByTagButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            removeByTagButton.heightAnchor.constraint(equalToConstant: 48),
            
            removeAllButton.topAnchor.constraint(equalTo: tagTextField.bottomAnchor, constant: 20),
            removeAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeAllButton.widthAnchor.constraint(equalToConstant: 180),
            removeAllButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func playTapped() {
        DispatchQueue.main.async { [weak self] in 
            guard let self else { return }
            isPlaying = true
            VxHub.shared.createAndPlayAnimation(
                name: "lottieExample",
                in: containerView,
                tag: animationTag,
                loopAnimation: loopSwitch.isOn,
                contentMode: .scaleAspectFit
            ) {
                DispatchQueue.main.async { [weak self] in
                    self?.isPlaying = false
                }
            }
        }
    }
    
    @objc private func stopTapped() {
        isPlaying = false
        VxHub.shared.stopAnimation(with: animationTag)
    }
    
    @objc private func removeByTagTapped() {
        guard let tagText = tagTextField.text, let tag = Int(tagText) else {
            // Show alert for invalid tag
            let alert = UIAlertController(
                title: "Invalid Tag",
                message: "Please enter a valid number",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        VxHub.shared.removeAnimation(with: tag)
        tagTextField.text = ""
        tagTextField.resignFirstResponder()
    }
    
    @objc private func removeAllTapped() {
        VxHub.shared.removeAllAnimations()
        isPlaying = false
    }
    
    @objc private func loopSwitchChanged() {
        if isPlaying {
            stopTapped()
            playTapped()
        }
    }
}

#Preview {
    LottieUIKitWrapper()
}
