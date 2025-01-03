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
    private let playButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let removeAllButton = UIButton(type: .system)
    private let loopSwitch = UISwitch()
    private let loopLabel = UILabel()
    private let titleLabel = UILabel()
    private let tagTextField = UITextField()
    private let removeByTagButton = UIButton(type: .system)
    private let animationTag = 100
    
    private var isPlaying = false {
        didSet {
//            playButton.isEnabled = !isPlaying
//            stopButton.isEnabled = isPlaying
        }
    }
    
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
        
        // Loop Control
        loopLabel.text = "Loop Animation"
        loopSwitch.addTarget(self, action: #selector(loopSwitchChanged), for: .valueChanged)
        
        // Tag TextField
        tagTextField.placeholder = "Enter animation tag"
        tagTextField.borderStyle = .roundedRect
        tagTextField.keyboardType = .numberPad
        
        // Buttons
        setupButtons()
        
        // Layout
        [titleLabel, containerView, loopLabel, loopSwitch, 
         playButton, stopButton, tagTextField, removeByTagButton, removeAllButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupButtons() {
        // Play Button
        playButton.setTitle("Play", for: .normal)
        playButton.backgroundColor = .systemBlue
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = 8
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        // Stop Button
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8
        stopButton.isEnabled = true
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        
        // Remove By Tag Button
        removeByTagButton.setTitle("Remove Tag", for: .normal)
        removeByTagButton.backgroundColor = .systemOrange
        removeByTagButton.setTitleColor(.white, for: .normal)
        removeByTagButton.layer.cornerRadius = 8
        removeByTagButton.addTarget(self, action: #selector(removeByTagTapped), for: .touchUpInside)
        
        // Remove All Button
        removeAllButton.setTitle("Remove All", for: .normal)
        removeAllButton.backgroundColor = .systemPurple
        removeAllButton.setTitleColor(.white, for: .normal)
        removeAllButton.layer.cornerRadius = 8
        removeAllButton.addTarget(self, action: #selector(removeAllTapped), for: .touchUpInside)
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
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            stopButton.topAnchor.constraint(equalTo: playButton.topAnchor),
            stopButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 44),
            
            tagTextField.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            tagTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tagTextField.widthAnchor.constraint(equalToConstant: 150),
            tagTextField.heightAnchor.constraint(equalToConstant: 44),
            
            removeByTagButton.topAnchor.constraint(equalTo: tagTextField.topAnchor),
            removeByTagButton.leadingAnchor.constraint(equalTo: tagTextField.trailingAnchor, constant: 8),
            removeByTagButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            removeByTagButton.heightAnchor.constraint(equalToConstant: 44),
            
            removeAllButton.topAnchor.constraint(equalTo: tagTextField.bottomAnchor, constant: 20),
            removeAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeAllButton.widthAnchor.constraint(equalToConstant: 150),
            removeAllButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func playTapped() {
        isPlaying = true
        VxHub.shared.createAndPlayAnimation(
            name: "lottieExample",
            in: containerView,
            tag: animationTag,
            loopAnimation: loopSwitch.isOn
        ) { [weak self] in
            self?.isPlaying = false
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
