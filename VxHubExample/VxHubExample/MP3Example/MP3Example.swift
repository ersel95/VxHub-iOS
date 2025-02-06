//
//  MP3Example.swift
//  VxHubExample
//
//  Created by furkan on 3.01.2025.
//

import SwiftUI
import VxHub
import AVFoundation

struct MP3TestView: View {
    @State private var isPlaying = false
    @State private var isRecording = false
    @State private var currentProgress: Float = 0
    @State private var volume: Float = 1.0
    @State private var playbackRate: Float = 1.0
    @State private var currentAudioId = "testAudio" 
    @State private var currentRecordingId = "testRecording_\(UUID().uuidString)"
    @State private var savedRecordings: [String] = []
    
    private let mp3Manager = VxMP3Manager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Playback Controls
                Group {
                    Text("Playback Controls")
                        .font(.title)
                        .bold()
                    
                    Button(action: playBundledAudio) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Play Bundled Audio")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Progress Bar
                    ProgressView(value: Double(currentProgress))
                        .padding(.horizontal)
                    Text("Progress: \(Int(currentProgress * 100))%")
                    
                    // Volume Control
                    HStack {
                        Image(systemName: "speaker.fill")
                        Slider(value: $volume, in: 0...1) { _ in
                            mp3Manager.setVolume(volume, for: currentAudioId)
                        }
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .padding(.horizontal)
                    
                    // Playback Rate
                    HStack {
                        Image(systemName: "speedometer")
                        Slider(value: $playbackRate, in: 0.5...2) { _ in
                            mp3Manager.setPlaybackRate(playbackRate, for: currentAudioId)
                        }
                        Text(String(format: "%.1fx", playbackRate))
                    }
                    .padding(.horizontal)
                }
                 
                // Playback Actions
                Group {
                    HStack(spacing: 15) {
                        Button(action: {
                            if isPlaying {
                                mp3Manager.pause(audioId: currentAudioId)
                            } else {
                                mp3Manager.resume(audioId: currentAudioId) { progress in
                                    DispatchQueue.main.async {
                                        currentProgress = progress
                                    }
                                }
                            }
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            mp3Manager.stop(audioId: currentAudioId)
                            isPlaying = false
                            currentProgress = 0
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Divider()
                
                // Recording Controls
                Group {
                    Text("Recording Controls")
                        .font(.title)
                        .bold()
                    
                    Button(action: toggleRecording) {
                        HStack {
                            Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                            Text(isRecording ? "Stop Recording" : "Start Recording")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Recorded Audio List
                    if !savedRecordings.isEmpty {
                        Text("Recorded Audio Files")
                            .font(.headline)
                        
                        ForEach(savedRecordings, id: \.self) { audioId in
                            Button(action: { playRecordedAudio(audioId: audioId) }) {
                                HStack {
                                    Image(systemName: "play.circle")
                                    Text(audioId)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                loadSavedRecordings()
            }
        }
        .navigationTitle("MP3 Manager Test")
    }
    
    private func playBundledAudio() {
        guard let url = Bundle.main.url(forResource: "test_audio", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        let config = VxAudioConfiguration(
            duckOthers: true,
            allowMixing: false,
            playbackRate: playbackRate,
            volume: volume,
            numberOfLoops: 0
        )
        
        mp3Manager.play(
            audioId: currentAudioId,
            url: url,
            configuration: config,
            onProgress: { progress in
                DispatchQueue.main.async {
                    currentProgress = progress
                }
            },
            onComplete: {
                DispatchQueue.main.async {
                    isPlaying = false
                    currentProgress = 0
                }
            },
            onError: { error in
                print("Error playing audio: \(error)")
            }
        )
        
        isPlaying = true
    }
    
    private func toggleRecording() {
        if isRecording {
            mp3Manager.stopRecording(save: true) { success, savedFileName in
                if success {
                    if let fileName = savedFileName {
                        DispatchQueue.main.async {
                            savedRecordings.append(fileName)
                            currentRecordingId = "recording_\(savedRecordings.count + 1)"
                            loadSavedRecordings()
                        }
                    }
                }
                DispatchQueue.main.async {
                    isRecording = false
                }
            }
        } else {
            mp3Manager.startRecording(
                recordingFileName: currentRecordingId,
                onStart: {
                    DispatchQueue.main.async {
                        isRecording = true
                        debugPrint("Recording started")
                    }
                },
                onError: { error in
                    print("Recording error: \(error)")
                    DispatchQueue.main.async {
                        isRecording = false
                    }
                }
            )
        }
    }
    
    private func playRecordedAudio(audioId: String) {
        guard let audioUrl = mp3Manager.getRecordingURL(for: audioId) else {
            print("Could not find recording: \(audioId)")
            return
        }
        
        let config = VxAudioConfiguration(
            duckOthers: true,
            allowMixing: false,
            playbackRate: playbackRate,
            volume: volume,
            numberOfLoops: 0
        )
        
        mp3Manager.play(
            audioId: audioId,
            url: audioUrl,
            configuration: config,
            onProgress: { progress in
                DispatchQueue.main.async {
                    if audioId == currentAudioId {
                        currentProgress = progress
                    }
                }
            },
            onComplete: {
                DispatchQueue.main.async {
                    if audioId == currentAudioId {
                        isPlaying = false
                        currentProgress = 0
                    }
                }
            }
        )
        
        currentAudioId = audioId
        isPlaying = true
    }
    
    private func loadSavedRecordings() {
        savedRecordings = mp3Manager.fetchSavedRecordings()
    }
}

#Preview {
    NavigationView {
        MP3TestView()
    }
}
