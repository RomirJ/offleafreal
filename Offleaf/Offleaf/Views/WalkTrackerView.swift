//
//  WalkTrackerView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI
import AVFoundation
import AudioToolbox
import UIKit

struct WalkSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let steps: Int?
    
    init(date: Date, duration: TimeInterval, steps: Int? = nil) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.steps = steps
    }
}

class WalkManager: ObservableObject {
    @Published var sessions: [WalkSession] = []
    @Published var currentDuration: TimeInterval = 0
    @Published var isWalking = false
    
    private var timer: Timer?
    private var startTime: Date?
    private let saveKey = "WalkSessions"
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        loadSessions()
        setupAudioPlayer()
    }
    
    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([WalkSession].self, from: data) {
            sessions = decoded
        }
    }
    
    private func setupAudioPlayer() {
        // Setup audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        if let asset = NSDataAsset(name: "RelaxingGuitar") {
            do {
                audioPlayer = try AVAudioPlayer(data: asset.data)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.6 // Set a comfortable volume
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to load audio file: \(error)")
            }
        }
    }
    
    func startWalk() {
        isWalking = true
        startTime = Date()
        currentDuration = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let start = self.startTime {
                self.currentDuration = Date().timeIntervalSince(start)
            }
        }
        
        // Play the relaxing guitar loop
        audioPlayer?.play()
    }
    
    func stopWalk() {
        isWalking = false
        timer?.invalidate()
        timer = nil
        
        // Stop the audio
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 // Reset to beginning for next time
        
        if currentDuration > 0 {
            let session = WalkSession(
                date: Date(),
                duration: currentDuration,
                steps: nil // Could integrate with HealthKit later
            )
            sessions.insert(session, at: 0)
            save()
        }
        
        currentDuration = 0
        startTime = nil
        
        // Play completion sound
        AudioServicesPlaySystemSound(1055)
    }

    func cancelActiveWalk() {
        guard isWalking else { return }
        isWalking = false
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentDuration = 0
        startTime = nil
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WalkTrackerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var walkManager = WalkManager()
    @State private var showingTips = false
    @State private var pulseAnimation = false
    
    let motivationalQuotes = [
        "Every step counts",
        "Movement is medicine",
        "Clear your mind, move your body",
        "Walking away from temptation",
        "Fresh air, fresh perspective",
        "One step at a time",
        "Your health matters"
    ]
    
    @State private var currentQuote = ""
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Animated gradient when walking
            if walkManager.isWalking {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.2).opacity(0.3),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2), value: walkManager.isWalking)
            }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { 
                        if walkManager.isWalking {
                            walkManager.stopWalk()
                        }
                        dismiss() 
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Go for a Walk")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingTips = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Timer display
                        VStack(spacing: 24) {
                            if walkManager.isWalking {
                                // Walking animation
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.1))
                                        .frame(width: 200, height: 200)
                                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                                    
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                                    Color(red: 0.25, green: 0.6, blue: 0.35)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                        .frame(width: 180, height: 180)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "figure.walk")
                                            .font(.system(size: 48, weight: .medium))
                                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                        
                                        Text(walkManager.formatDuration(walkManager.currentDuration))
                                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                    }
                                }
                                .onAppear {
                                    pulseAnimation = true
                                }
                            } else {
                                // Start state
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 200, height: 200)
                                    
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 60, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                        }
                        .padding(.top, 40)
                        
                        // Motivational quote
                        if !currentQuote.isEmpty {
                            Text(currentQuote)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .transition(.opacity)
                        }
                        
                        // Start/Stop button
                        Button(action: {
                            if walkManager.isWalking {
                                walkManager.stopWalk()
                            } else {
                                walkManager.startWalk()
                                currentQuote = motivationalQuotes.randomElement() ?? ""
                            }
                        }) {
                            HStack {
                                Image(systemName: walkManager.isWalking ? "stop.fill" : "play.fill")
                                    .font(.system(size: 20, weight: .medium))
                                Text(walkManager.isWalking ? "End Walk" : "Start Walking")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(walkManager.isWalking ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                walkManager.isWalking ?
                                AnyView(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.white)
                                ) :
                                AnyView(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                                    Color(red: 0.25, green: 0.6, blue: 0.35)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                            )
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 10, y: 4)
                        }
                        .padding(.horizontal, 40)
                        
                        // Recent walks
                        if !walkManager.sessions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Walks")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                VStack(spacing: 8) {
                                    ForEach(walkManager.sessions.prefix(5)) { session in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(session.date, style: .date)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.8))
                                                
                                                Text(session.date, style: .time)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                            
                                            Spacer()
                                            
                                            Text(walkManager.formatDuration(session.duration))
                                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.05))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            walkManager.cancelActiveWalk()
        }
        .onAppear {
            if !walkManager.isWalking {
                currentQuote = motivationalQuotes.randomElement() ?? ""
            }
        }
        .sheet(isPresented: $showingTips) {
            WalkingTipsView()
        }
    }
}

struct WalkingTipsView: View {
    @Environment(\.dismiss) var dismiss
    
    let tips = [
        ("Start small", "Even a 5-minute walk helps clear your mind"),
        ("Choose nature", "Parks and green spaces boost mood"),
        ("No phone", "Leave distractions behind for mental clarity"),
        ("Breathe deeply", "Focus on your breathing as you walk"),
        ("Notice surroundings", "Practice mindfulness by observing"),
        ("Walk daily", "Consistency builds healthy habits"),
        ("Invite someone", "Walking with others provides support")
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("Walking Tips")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(tips, id: \.0) { title, description in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct WalkTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        WalkTrackerView()
    }
}
