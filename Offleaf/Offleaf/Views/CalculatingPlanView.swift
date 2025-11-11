//
//  CalculatingPlanView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct CalculatingPlanView: View {
    @State private var progress: Double = 0
    @State private var displayProgress: Int = 0
    @State private var showDone = false
    @State private var showCheckmark = false
    var onComplete: () -> Void
    
    let timer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Black background with gradient
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.green.opacity(0.15),
                        Color.green.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Leaf logo at top
                LeafLogoView(size: 60)
                    .padding(.top, 100)
                
                Spacer()
                
                // Progress circle or checkmark
                ZStack {
                    if !showDone {
                        // Progress circle
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                                .frame(width: 160, height: 160)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.7, blue: 0.3),
                                            Color(red: 0.3, green: 0.8, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 2.5), value: progress)
                            
                            // Percentage text
                            Text("\(displayProgress)%")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    } else {
                        // Done state with checkmark
                        ZStack {
                            // Circle with checkmark
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.7, blue: 0.3),
                                            Color(red: 0.3, green: 0.8, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 160, height: 160)
                            
                            // Checkmark
                            if showCheckmark {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 60, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                    .scaleEffect(showCheckmark ? 1 : 0.5)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
                            }
                        }
                    }
                }
                
                Spacer().frame(height: 40)
                
                // Text
                if !showDone {
                    VStack(spacing: 8) {
                        Text("Calculating your")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                        Text("personalized plan.")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .transition(.opacity)
                } else {
                    Text("Done!")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            // Update display progress to match actual progress
            if displayProgress < 100 && progress > 0 {
                let targetProgress = Int(progress * 100)
                if displayProgress < targetProgress {
                    displayProgress = min(displayProgress + 1, 100)
                }
            }
        }
        .onAppear {
            // Start animation after a brief delay to ensure 0% is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Animate progress from 0 to 100%
                withAnimation(.linear(duration: 2.5)) {
                    progress = 1.0
                }
            }
            
            // After progress completes, show Done state
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                timer.upstream.connect().cancel()
                withAnimation(.easeInOut(duration: 0.3)) {
                    showDone = true
                }
                
                // Show checkmark with spring animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showCheckmark = true
                }
                
                // Complete onboarding after showing Done
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onComplete()
                }
            }
        }
    }
}

struct CalculatingPlanView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatingPlanView(onComplete: {})
    }
}