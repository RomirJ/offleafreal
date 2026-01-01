//
//  CalculatingPlanView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI
import Combine
import UIKit

struct CalculatingPlanView: View {
    @State private var progress: Double = 0
    @State private var displayProgress: Int = 0
    @State private var showDone = false
    @State private var showCheckmark = false
    @State private var timerCancellable: AnyCancellable?
    var onComplete: () -> Void
    
    // Animation states
    @State private var leafScale: CGFloat = 0
    @State private var leafRotation: Double = 0
    @State private var leafFloat: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var circleScale: CGFloat = 0
    @State private var showText = false
    @State private var currentMessage = 0
    @State private var ellipsisCount = 0
    @State private var backgroundOffset: CGFloat = 0
    @State private var particleOffset: [CGFloat] = Array(repeating: 0, count: 5)
    @State private var particleOpacity: [Double] = Array(repeating: 0, count: 5)
    @State private var progressGlow: Double = 0
    @State private var completionScale: CGFloat = 1.0
    @State private var showSuccessRing = false
    
    let timer = Timer.publish(every: 0.025, on: .main, in: .common)
    let ellipsisTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    let messages = [
        "Analyzing your responses",
        "Building your journey",
        "Personalizing your experience",
        "Almost ready"
    ]
    
    var ellipsis: String {
        String(repeating: ".", count: ellipsisCount)
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Moving gradient overlay
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.1, green: 0.3, blue: 0.15).opacity(0.3),
                        Color(red: 0.15, green: 0.4, blue: 0.2).opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .offset(y: backgroundOffset)
                
                // Radial glow effect
                RadialGradient(
                    colors: [
                        Color(red: 0.3, green: 0.7, blue: 0.4).opacity(glowOpacity * 0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
                .ignoresSafeArea()
                .scaleEffect(pulseScale)
                
                // Floating particles
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.3),
                                    Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 20...40))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: particleOffset[index]
                        )
                        .opacity(particleOpacity[index])
                        .blur(radius: 2)
                }
            }
            
            VStack(spacing: 0) {
                // Leaf logo with animations
                ZStack {
                    // Pulsing background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseScale * 1.2)
                        .opacity(glowOpacity * 0.5)
                    
                    LeafLogoView(size: 160)
                        .scaleEffect(leafScale)
                        .rotationEffect(.degrees(leafRotation))
                        .offset(y: leafFloat)
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5), radius: 20, y: 10)
                }
                .padding(.top, 80)
                
                Spacer()
                
                // Progress circle or checkmark
                ZStack {
                    if !showDone {
                        // Progress circle with enhancements
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.1),
                                            Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 20
                                )
                                .frame(width: 180, height: 180)
                                .blur(radius: 10)
                                .opacity(progressGlow)
                            
                            // Background circle
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 160, height: 160)
                                .scaleEffect(circleScale)
                            
                            // Progress circle with gradient
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.8, blue: 0.3),
                                            Color(red: 0.4, green: 0.9, blue: 0.5),
                                            Color(red: 0.3, green: 0.85, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .scaleEffect(circleScale)
                                .shadow(color: Color(red: 0.3, green: 0.8, blue: 0.4), radius: 5)
                                .animation(.linear(duration: 2.5), value: progress)
                            
                            // Leading edge glow
                            if progress > 0 && progress < 1 {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.9, blue: 0.5),
                                                Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.5),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 10
                                        )
                                    )
                                    .frame(width: 12, height: 12)
                                    .offset(x: 80 * cos(CGFloat(progress * 2 * .pi - .pi/2)),
                                            y: 80 * sin(CGFloat(progress * 2 * .pi - .pi/2)))
                                    .blur(radius: 2)
                            }
                            
                            // Percentage text with scale effect
                            VStack {
                                Text("\(displayProgress)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .white,
                                                Color(red: 0.9, green: 0.95, blue: 0.9)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaleEffect(displayProgress % 10 == 0 ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: displayProgress)
                                
                                Text("%")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .offset(y: -5)
                            }
                        }
                    } else {
                        // Enhanced done state
                        ZStack {
                            // Success ring animation
                            if showSuccessRing {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.9, blue: 0.4).opacity(0.5),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 200, height: 200)
                                    .scaleEffect(showSuccessRing ? 1.5 : 1)
                                    .opacity(showSuccessRing ? 0 : 1)
                                    .animation(.easeOut(duration: 0.8), value: showSuccessRing)
                            }
                            
                            // Circle with gradient
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.9, blue: 0.4),
                                            Color(red: 0.2, green: 0.8, blue: 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                                .frame(width: 160, height: 160)
                                .scaleEffect(completionScale)
                                .shadow(color: Color(red: 0.3, green: 0.8, blue: 0.4), radius: 15)
                            
                            // Filled circle background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.1),
                                            Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 156, height: 156)
                                .scaleEffect(completionScale)
                            
                            // Animated checkmark
                            if showCheckmark {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.9, blue: 0.5),
                                                Color(red: 0.3, green: 0.8, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(showCheckmark ? 1 : 0.5)
                                    .rotationEffect(.degrees(showCheckmark ? 0 : -180))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showCheckmark)
                            }
                        }
                    }
                }
                
                Spacer().frame(height: 40)
                
                // Animated text
                if !showDone {
                    VStack(spacing: 16) {
                        if currentMessage < messages.count {
                            Text(messages[currentMessage] + ellipsis)
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white)
                                .opacity(showText ? 1 : 0)
                                .scaleEffect(showText ? 1 : 0.8)
                                .animation(.easeOut(duration: 0.4), value: showText)
                                .animation(.easeInOut(duration: 0.3), value: currentMessage)
                        }
                        
                        Text("This may take a moment")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                            .opacity(showText ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: showText)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                } else {
                    VStack(spacing: 8) {
                        Text("All set!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color(red: 0.9, green: 0.95, blue: 0.9)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(showDone ? 1 : 0.5)
                            .opacity(showDone ? 1 : 0)
                        
                        Text("Your personalized plan is ready")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(showDone ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: showDone)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
        .onReceive(ellipsisTimer) { _ in
            updateEllipsis()
        }
        .onDisappear {
            cleanupTimers()
        }
    }
    
    private func startAnimations() {
        // Connect the main timer
        timerCancellable = AnyCancellable(timer.connect())
        
        // Leaf entrance animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            leafScale = 1.0
        }
        
        // Leaf floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            leafFloat = -10
        }
        
        // Leaf rotation
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            leafRotation = 5
        }
        
        // Circle entrance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            circleScale = 1.0
        }
        
        // Show text
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            showText = true
        }
        
        // Background glow
        withAnimation(.easeOut(duration: 1).delay(0.3)) {
            glowOpacity = 1.0
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            pulseScale = 1.15
        }
        
        // Progress glow
        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(0.5)) {
            progressGlow = 1.0
        }
        
        // Background movement
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            backgroundOffset = 30
        }
        
        // Particle animations
        for index in 0..<5 {
            let delay = Double(index) * 0.3
            withAnimation(.easeInOut(duration: Double.random(in: 3...5)).repeatForever(autoreverses: false).delay(delay)) {
                particleOffset[index] = -UIScreen.main.bounds.height - 100
            }
            withAnimation(.easeOut(duration: 1).delay(delay)) {
                particleOpacity[index] = 1.0
            }
        }
        
        // Start progress animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 2.5)) {
                progress = 1.0
            }
        }
        
        // Message rotation
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            if !showDone && currentMessage < messages.count - 1 {
                withAnimation {
                    currentMessage += 1
                }
            }
        }
        
        // Completion sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            completeLoading()
        }
    }
    
    private func updateProgress() {
        if displayProgress < 100 && progress > 0 {
            let targetProgress = Int(progress * 100)
            if displayProgress < targetProgress {
                displayProgress = min(displayProgress + 1, 100)
                
                // Haptic feedback at milestones
                if displayProgress == 25 || displayProgress == 50 || displayProgress == 75 || displayProgress == 100 {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    private func updateEllipsis() {
        ellipsisCount = (ellipsisCount + 1) % 4
    }
    
    private func completeLoading() {
        // Cancel the timer
        timerCancellable?.cancel()
        timerCancellable = nil
        
        // Success feedback
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        // Completion animations
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            completionScale = 1.1
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.15)) {
            completionScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showDone = true
            showText = false
        }
        
        // Show checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showCheckmark = true
            showSuccessRing = true
        }
        
        // Leaf celebration
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            leafScale = 1.2
            leafRotation = 360
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            leafScale = 1.0
            leafRotation = 0
        }
        
        // Navigate to next screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                leafScale = 0.8
                circleScale = 0.8
                showText = false
                glowOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
    
    private func cleanupTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

struct CalculatingPlanView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatingPlanView(onComplete: {})
    }
}