//
//  File.swift
//  VxHub
//
//  Created by furkan on 3.01.2025.
//

import Foundation
import AVFoundation

public struct VxAudioConfiguration : Sendable{
    let duckOthers: Bool
    let allowMixing: Bool
    let playbackRate: Float
    let volume: Float
    let numberOfLoops: Int // -1 for infinite
    
    public init(
        duckOthers: Bool = true,
        allowMixing: Bool = false,
        playbackRate: Float = 1.0,
        volume: Float = 1.0,
        numberOfLoops: Int = 0
    ) {
        self.duckOthers = duckOthers
        self.allowMixing = allowMixing
        self.playbackRate = playbackRate
        self.volume = volume
        self.numberOfLoops = numberOfLoops
    }
}

final public class VxMP3Manager: NSObject, @unchecked Sendable {
    // MARK: - Properties
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var audioRecorder: AVAudioRecorder?
    private var progressTimers: [String: Timer] = [:]
    private var completionHandlers: [String: () -> Void] = [:]
    private var progressHandlers: [String: (Float) -> Void] = [:]
    private var currentRecordingId: String?
    private let audioQueue = DispatchQueue(label: "vx.mp3.player.queue")
    private let responseQueue = DispatchQueue.main
    
    private struct Static {
        nonisolated(unsafe) fileprivate static var instance: VxMP3Manager?
    }
    
    public class var shared: VxMP3Manager {
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            Static.instance = VxMP3Manager()
            return Static.instance!
        }
    }
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        dispose()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, 
                                                          options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            VxLogger.shared.error("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio Playback
    public func play(
        audioId: String,
        url: URL,
        configuration: VxAudioConfiguration = VxAudioConfiguration(),
        onProgress: (@Sendable(Float) -> Void)? = nil,
        onComplete: (@Sendable() -> Void)? = nil,
        onError: (@Sendable(Error) -> Void)? = nil
    ) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                if configuration.duckOthers {
                    try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
                } else if configuration.allowMixing {
                    try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
                }
                
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                player.enableRate = true
                player.rate = configuration.playbackRate
                player.volume = configuration.volume
                player.numberOfLoops = configuration.numberOfLoops
                
                self.audioPlayers[audioId] = player
                
                if let onComplete = onComplete {
                    self.completionHandlers[audioId] = {
                        self.responseQueue.async {
                            onComplete()
                        }
                    }
                }
                
                if let onProgress = onProgress {
                    self.progressHandlers[audioId] = { progress in
                        self.responseQueue.async {
                            onProgress(progress)
                        }
                    }
                }
                
                if player.prepareToPlay() && player.play() {
                    self.startProgressTimer(for: audioId)
                }
            } catch {
                self.responseQueue.async {
                    onError?(error)
                }
            }
        }
    }
    
    public func pause(
        audioId: String,
        completion: (@Sendable() -> Void)? = nil
    ) {
        audioQueue.async { [weak self] in
            guard let self = self,
                  let player = self.audioPlayers[audioId] else {
                self?.responseQueue.async {
                    completion?()
                }
                return
            }
            
            player.pause()
            self.stopProgressTimer(for: audioId)
            
            self.responseQueue.async {
                completion?()
            }
        }
    }
    
    public func resume(
        audioId: String,
        onProgress: (@Sendable(Float) -> Void)? = nil,
        completion: (@Sendable() -> Void)? = nil
    ) {
        audioQueue.async { [weak self] in
            guard let self = self,
                  let player = self.audioPlayers[audioId] else {
                self?.responseQueue.async {
                    completion?()
                }
                return
            }
            
            if let onProgress = onProgress {
                self.progressHandlers[audioId] = { progress in
                    self.responseQueue.async {
                        onProgress(progress)
                    }
                }
            }
            
            if player.play() {
                self.startProgressTimer(for: audioId)
            }
            
            self.responseQueue.async {
                completion?()
            }
        }
    }
    
    public func stop(
        audioId: String,
        completion: (@Sendable() -> Void)? = nil
    ) {
        audioQueue.async { [weak self] in
            guard let self = self,
                  let player = self.audioPlayers[audioId] else {
                self?.responseQueue.async {
                    completion?()
                }
                return
            }
            
            player.stop()
            player.currentTime = 0
            self.stopProgressTimer(for: audioId)
            self.audioPlayers.removeValue(forKey: audioId)
            
            self.responseQueue.async {
                completion?()
            }
        }
    }
    
    public func stopAll(completion: (() -> Void)? = nil) {
        audioPlayers.forEach { (audioId, player) in
            player.stop()
            stopProgressTimer(for: audioId)
        }
        audioPlayers.removeAll()
        completion?()
    }
    
    // MARK: - Recording
    public func startRecording(
        recordingId: String,
        onStart: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        let permManager = VxPermissionManager()
        guard permManager.isMicrophonePermissionGranted() else {
            VxLogger.shared.log("Microphone permission not granted call VxPermissionManager - Request Mic Access", level: .error, type: .error)
            return }
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(recordingId).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            
            if audioRecorder?.record() == true {
                debugPrint("Recing")
                currentRecordingId = recordingId
                onStart?()
            }else{
                VxLogger.shared.log("Microphone permission not granted call VxPermissionManager - Request Mic Access", level: .error, type: .error)
            }
        } catch {
            onError?(error)
        }
    }
    
    public func stopRecording(completion: ((Bool) -> Void)? = nil) {
        guard currentRecordingId != nil else {
            completion?(false)
            return
        }
        audioRecorder?.stop()
        currentRecordingId = nil
        completion?(true)
    }
    
    // MARK: - Utilities
    public func setVolume(_ volume: Float, for audioId: String) {
        audioPlayers[audioId]?.volume = volume
    }
    
    public func setPlaybackRate(_ rate: Float, for audioId: String) {
        audioPlayers[audioId]?.rate = rate
    }
    
    public func getCurrentTime(for audioId: String) -> TimeInterval? {
        return audioPlayers[audioId]?.currentTime
    }
    
    public func getDuration(for audioId: String) -> TimeInterval? {
        return audioPlayers[audioId]?.duration
    }
    
    public func isPlaying(audioId: String) -> Bool {
        return audioPlayers[audioId]?.isPlaying ?? false
    }
    
    // MARK: - Progress Tracking
    private func startProgressTimer(for audioId: String) {
        stopProgressTimer(for: audioId)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.audioQueue.async { [weak self] in
                guard let self = self,
                      let player = self.audioPlayers[audioId] else { return }
                
                let progress = Float(player.currentTime / player.duration)
                self.progressHandlers[audioId]?(progress)
            }
        }
        
        progressTimers[audioId] = timer
    }
    
    private func stopProgressTimer(for audioId: String) {
        progressTimers[audioId]?.invalidate()
        progressTimers.removeValue(forKey: audioId)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Cleanup
    public func dispose() {
        stopAll()
        stopRecording()
        progressTimers.forEach { $0.value.invalidate() }
        progressTimers.removeAll()
        completionHandlers.removeAll()
        progressHandlers.removeAll()
        VxMP3Manager.Static.instance = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            VxLogger.shared.error("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension VxMP3Manager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let audioId = self.audioPlayers.first(where: { $0.value === player })?.key {
            audioQueue.async { [weak self] in
                guard let self = self else { return }
                self.stopProgressTimer(for: audioId)
                self.audioPlayers.removeValue(forKey: audioId)
                
                self.responseQueue.async {
                    self.completionHandlers[audioId]?()
                    self.completionHandlers.removeValue(forKey: audioId)
                    self.progressHandlers.removeValue(forKey: audioId)
                }
            }
        }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            VxLogger.shared.error("Audio player decode error: \(error.localizedDescription)")
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension VxMP3Manager: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        currentRecordingId = nil
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            VxLogger.shared.error("Audio recorder encode error: \(error.localizedDescription)")
        }
    }
}
