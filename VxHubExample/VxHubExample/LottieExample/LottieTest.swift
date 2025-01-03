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
    private let loopSwitch = UISwitch()
    private let loopLabel = UILabel()
    private let titleLabel = UILabel()
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
        
        // Buttons
        playButton.setTitle("Play", for: .normal)
        playButton.backgroundColor = .systemBlue
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = 8
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        stopButton.setTitle("Stop", for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8
        stopButton.isEnabled = true
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        
        // Layout
        [titleLabel, containerView, loopLabel, loopSwitch, playButton, stopButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
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
            stopButton.heightAnchor.constraint(equalToConstant: 44)
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
