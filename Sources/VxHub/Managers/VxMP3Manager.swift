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
        fileprivate static let lock = NSLock()
        nonisolated(unsafe) fileprivate static var instance: VxMP3Manager?
    }

    public class var shared: VxMP3Manager {
        Static.lock.lock()
        defer { Static.lock.unlock() }
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            let newInstance = VxMP3Manager()
            Static.instance = newInstance
            return newInstance
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
            
            if self.audioRecorder?.isRecording == true {
                self.stopRecording { _ , _ in
                    self.responseQueue.async {
                        VxLogger.shared.log("Recording stopped due to playback request", level: .warning, type: .warning)
                    }
                }
            }
            
            let currentPlayers = self.audioPlayers
            currentPlayers.forEach { (currentAudioId, player) in
                if currentAudioId != audioId {
                    player.pause()
                    self.stopProgressTimer(for: currentAudioId)
                }
            }
            
            do {
                #if os(iOS)
                if configuration.duckOthers {
                    try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
                } else if configuration.allowMixing {
                    try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
                }
                #endif
                
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
        audioQueue.sync { [weak self] in
            guard let self = self else { return }
            self.audioPlayers.forEach { (audioId, player) in
                player.stop()
                self.stopProgressTimer(for: audioId)
            }
            self.audioPlayers.removeAll()
        }
        completion?()
    }
    
    // MARK: - Recording
    public func startRecording(
        recordingFileName: String,
        onStart: (@Sendable() -> Void)? = nil,
        onError: (@Sendable(Error) -> Void)? = nil
    ) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            let currentPlayers = self.audioPlayers
            currentPlayers.forEach { (audioId, player) in
                player.pause()
                self.stopProgressTimer(for: audioId)
            }
            
//            let permManager = VxPermissionManager()
//            guard permManager.isMicrophonePermissionGranted() else {
//                self.responseQueue.async {
//                    VxLogger.shared.log("Microphone permission not granted call VxPermissionManager - Request Mic Access", level: .error, type: .error)
//                }
//                return
//            }
            
            // Clean up any existing recorder
            if self.audioRecorder != nil {
                self.audioRecorder?.stop()
                self.audioRecorder = nil
            }
            
            let audioFilename = self.getDocumentsDirectory().appendingPathComponent("\(recordingFileName).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                              options: [.defaultToSpeaker, .allowBluetooth])
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                
                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                self.audioRecorder?.delegate = self
                
                guard self.audioRecorder?.prepareToRecord() == true else {
                    self.responseQueue.async {
                        VxLogger.shared.log("Failed to prepare for recording", level: .error, type: .error)
                    }
                    return
                }
                
                guard self.audioRecorder?.record() == true else {
                    self.responseQueue.async {
                        VxLogger.shared.log("Failed to start recording", level: .error, type: .error)
                    }
                    return
                }
                
                self.currentRecordingId = recordingFileName
                self.responseQueue.async {
                    onStart?()
                }
            } catch {
                self.responseQueue.async {
                    onError?(error)
                }
            }
        }
    }
    
    public func stopRecording(save: Bool = false, completion: (@Sendable(Bool, String?) -> Void)? = nil) {
        audioQueue.async { [weak self] in
            guard let self = self else {
                self?.responseQueue.async { completion?(false, nil) }
                return
            }
            
            guard let currentRecordingId = self.currentRecordingId,
                  let recorder = self.audioRecorder else {
                self.responseQueue.async { completion?(false, nil) }
                return
            }
            
            let recordingURL = recorder.url
            recorder.stop()
            self.audioRecorder = nil
            self.currentRecordingId = nil
            
            #if os(iOS)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, 
                                                              options: [.defaultToSpeaker, .allowBluetooth])
            } catch {
                print("Failed to reset audio session after recording: \(error.localizedDescription)")
            }
            #endif
            
            if save {
                do {
                    let data = try Data(contentsOf: recordingURL)
                    let fileManager = VxFileManager()
                    fileManager.save(data, type: .baseDir, fileName: "\(currentRecordingId).m4a") { result in
                        switch result {
                        case .success:
                            self.responseQueue.async { completion?(true, currentRecordingId) }
                        case .failure:
                            self.responseQueue.async { completion?(false, nil) }
                        }
                    }
                } catch {
                    self.responseQueue.async { completion?(false, nil) }
                }
            } else {
                self.responseQueue.async { completion?(true, nil) }
            }
        }
    }
    
    // MARK: - Utilities
    public func setVolume(_ volume: Float, for audioId: String) {
        audioQueue.async { [weak self] in
            self?.audioPlayers[audioId]?.volume = volume
        }
    }

    public func setPlaybackRate(_ rate: Float, for audioId: String) {
        audioQueue.async { [weak self] in
            self?.audioPlayers[audioId]?.rate = rate
        }
    }

    public func getCurrentTime(for audioId: String) -> TimeInterval? {
        return audioQueue.sync { audioPlayers[audioId]?.currentTime }
    }

    public func getDuration(for audioId: String) -> TimeInterval? {
        return audioQueue.sync { audioPlayers[audioId]?.duration }
    }

    public func isPlaying(audioId: String) -> Bool {
        return audioQueue.sync { audioPlayers[audioId]?.isPlaying ?? false }
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
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.audioPlayers.forEach { (audioId, player) in
                player.stop()
                self.progressTimers[audioId]?.invalidate()
            }
            self.audioPlayers.removeAll()
            self.progressTimers.removeAll()
            self.completionHandlers.removeAll()
            self.progressHandlers.removeAll()

            Static.lock.lock()
            VxMP3Manager.Static.instance = nil
            Static.lock.unlock()

            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                VxLogger.shared.error("Failed to deactivate audio session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Fetch Saved Recordings
    public func fetchSavedRecordings() -> [String] {
        let fileManager = FileManager.default
        let vxFileManager = VxFileManager()
        let directoryURL = vxFileManager.vxHubDirectoryURL(for: .baseDir)
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryURL,
                                                          includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "m4a" }
                       .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            VxLogger.shared.error("Failed to fetch recordings: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Get Recording URL
    public func getRecordingURL(for recordingId: String) -> URL? {
        let vxFileManager = VxFileManager()
        let fileURL = vxFileManager.vxHubDirectoryURL(for: .baseDir)
                                  .appendingPathComponent("\(recordingId).m4a")
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension VxMP3Manager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let playerPtr = ObjectIdentifier(player)
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            guard let audioId = self.audioPlayers.first(where: { ObjectIdentifier($0.value) == playerPtr })?.key else { return }
            self.stopProgressTimer(for: audioId)
            self.audioPlayers.removeValue(forKey: audioId)

            self.responseQueue.async {
                self.completionHandlers[audioId]?()
                self.completionHandlers.removeValue(forKey: audioId)
                self.progressHandlers.removeValue(forKey: audioId)
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
            VxLogger.shared.log("audio recorder failed with error \(error.localizedDescription)", level: .error, type: .error)
        }
    }
}
