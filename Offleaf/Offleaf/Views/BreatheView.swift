//
//  BreatheView.swift
//  Offleaf
//
//  Created by Assistant on 10/15/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct BreatheView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isBreathingIn = true
    @State private var breathAnimation = false
    @State private var breathingScale: CGFloat = 0.6
    @State private var showContent = false
    @State private var cycleCount = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false
    @State private var breathTimer: Timer?
    
    // User's saved reasons (would come from storage)
    let userReasons = [
        "Be healthier and live longer",
        "Be a better parent",
        "Save money for travel"
    ]
    
    var body: some View {
        ZStack {
            // Black background like home screen
            Color.black
                .ignoresSafeArea()
            
            // Vibrant animated orb in background - matching home screen
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.3),  // Bright gold
                                Color(red: 0.95, green: 0.6, blue: 0.2), // Orange
                                Color(red: 0.9, green: 0.4, blue: 0.25), // Deep orange
                                Color(red: 0.85, green: 0.3, blue: 0.3).opacity(0.8), // Pink-red
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 35)
                    .offset(y: -80)
                    .opacity(showContent ? 0.35 : 0)
                    .scaleEffect(breathingScale * 0.8 + 0.4) // Subtle pulse with breathing
                    .animation(.easeInOut(duration: 4), value: breathingScale)
                
                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .offset(y: -50)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(breathingScale * 0.5 + 0.7)
                    .animation(.easeInOut(duration: 4), value: breathingScale)
            }
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer(minLength: 40)
                
                // Breathing Circle
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.2),
                                    Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 240, height: 240)
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.3),
                                    Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(breathingScale * 1.1)
                    
                    // Inner animated circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.6),
                                    Color(red: 1.0, green: 0.8, blue: 0.4),
                                    Color(red: 0.95, green: 0.7, blue: 0.3),
                                    Color(red: 0.9, green: 0.5, blue: 0.2)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(breathingScale)
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.5), radius: 30)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.3), lineWidth: 1)
                                .frame(width: 140, height: 140)
                                .scaleEffect(breathingScale)
                        )
                }
                
                // Breathing Text - closer to circle
                VStack(spacing: 8) {
                    Text(isBreathingIn ? "Breathe In..." : "Breathe Out...")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You're safe. This will pass.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 30)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                
                Spacer(minLength: 30)
                
                // Your Reasons Card - more visible
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your reasons to stay strong:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(userReasons, id: \.self) { reason in
                            HStack(spacing: 10) {
                                Text("•")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                Text(reason)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                
                Spacer(minLength: 20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Calm Audio Button
                    Button(action: toggleAudio) {
                        HStack {
                            Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                            Text(isPlayingAudio ? "Pause Audio" : "Calm Audio")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(isPlayingAudio ? Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15) : Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(isPlayingAudio ? Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3) : Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    
                    // I'm OK Button
                    Button(action: { 
                        audioPlayer?.stop()
                        dismiss() 
                    }) {
                        Text("I'm OK")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
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
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 10, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            showContent = true
            startBreathingAnimation()
            setupAudioPlayer()
        }
        .onDisappear {
            breathTimer?.invalidate()
            breathTimer = nil
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }
    
    func setupAudioPlayer() {
        if let asset = NSDataAsset(name: "RelaxingGuitar") {
            do {
                audioPlayer = try AVAudioPlayer(data: asset.data)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.7
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error)")
            }
        }
    }
    
    func toggleAudio() {
        if isPlayingAudio {
            audioPlayer?.pause()
            isPlayingAudio = false
        } else {
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }
    
    func startBreathingAnimation() {
        // Initial breath in
        withAnimation(.easeInOut(duration: 4)) {
            breathingScale = 1.0
        }
        
        // Invalidate any existing timer
        breathTimer?.invalidate()
        
        // Continuous breathing cycle
        breathTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            isBreathingIn.toggle()
            withAnimation(.easeInOut(duration: 4)) {
                breathingScale = isBreathingIn ? 1.0 : 0.6
            }
            
            cycleCount += 1
            
            // Optional: Auto-dismiss after certain cycles
            if cycleCount >= 10 {
                // User has done 10 breathing cycles
                HapticManager.shared.impact(style: .light)
            }
        }
    }
}

// Haptic feedback manager
class HapticManager {
    static let shared = HapticManager()
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        BreatheView()
    }
}
