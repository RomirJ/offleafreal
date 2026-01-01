//
//  SpinWheelView.swift
//  Offleaf
//
//  Discount spin wheel for cancelled purchases
//

import SwiftUI
import UIKit

struct SpinWheelView: View {
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var selectedDiscount = ""
    @State private var finalRotation: Double = 0
    @State private var viewOpacity: Double = 0
    @State private var wheelScale: CGFloat = 0.8
    @State private var contentOffset: CGFloat = 0
    @State private var arrowScale: CGFloat = 0
    @State private var showCelebration = false
    @State private var showSpecialOffer = false
    var onContinue: () -> Void
    var onDismiss: () -> Void
    
    // Wheel segments with discounts - matching exact design
    let segments = [
        ("70%", Color.white),
        ("50%", Color.black),
        ("No luck", Color.white),
        ("60%", Color.black),
        ("30%", Color.white),
        ("🎁", Color.black)
    ]
    
    var body: some View {
        if showSpecialOffer {
            SpecialOfferView(
                onDismiss: {
                    // Go back to pricing view (dismiss both spin wheel and special offer)
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSpecialOffer = false
                    }
                    onDismiss()
                },
                onComplete: onContinue
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Dark background
                    Color.black
                        .ignoresSafeArea()
                        .opacity(viewOpacity)
                
                VStack(spacing: 0) {
                    // Title with proper spacing
                    Text("Spin to unlock an\nexclusive discount")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 80)
                        .padding(.bottom, 20)
                    
                    // Wheel container with fixed frame to prevent shifting
                    ZStack {
                        // Spin wheel with proper segments
                        ZStack {
                            // Wheel background circle
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                .frame(width: 280, height: 280)
                            
                            // Wheel segments
                            ForEach(0..<segments.count, id: \.self) { index in
                                WheelSegment(
                                    startAngle: Angle(degrees: Double(index) * 60),
                                    endAngle: Angle(degrees: Double(index + 1) * 60),
                                    color: segments[index].1,
                                    text: segments[index].0,
                                    textColor: segments[index].1 == .white ? .black : .white
                                )
                            }
                            .frame(width: 280, height: 280)
                            
                            // Center circle with logo
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                            
                            // Celebration overlay for gift landing
                            if showCelebration {
                                ForEach(0..<6, id: \.self) { index in
                                    Image(systemName: "sparkle")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                        .offset(
                                            x: cos(Double(index) * .pi / 3) * 100,
                                            y: sin(Double(index) * .pi / 3) * 100
                                        )
                                        .scaleEffect(showCelebration ? 1.0 : 0)
                                        .opacity(showCelebration ? 0 : 1)
                                        .animation(
                                            Animation.easeOut(duration: 1.0)
                                                .delay(Double(index) * 0.1),
                                            value: showCelebration
                                        )
                                }
                            }
                        }
                        .frame(width: 280, height: 280)
                        .rotationEffect(Angle(degrees: rotation))
                        .scaleEffect(wheelScale)
                        .opacity(viewOpacity)
                        
                        // Arrow pointer at the top-right, angled to point at gift center
                        Triangle()
                            .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                            .frame(width: 35, height: 25)
                            .rotationEffect(.degrees(210)) // Angled more to the left
                            .offset(x: 75, y: -140) // Moved more to the right
                            .scaleEffect(arrowScale)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .frame(width: 350, height: 350) // Fixed frame to prevent shifting
                    
                    // Button container with fixed height to prevent layout shift
                    VStack {
                        Spacer()
                        
                        if showResult {
                            Button(action: {
                                // Show special offer when gift is won
                                if selectedDiscount == "🎁" {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        showSpecialOffer = true
                                    }
                                } else {
                                    onContinue()
                                }
                            }) {
                                Text("Continue")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.8, blue: 0.5),
                                                Color(red: 0.25, green: 0.7, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(30)
                                    .shadow(
                                        color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3),
                                        radius: 10,
                                        y: 5
                                    )
                                    .padding(.horizontal, 40)
                                    .scaleEffect(showResult ? 1.0 : 0.8)
                                    .opacity(showResult ? 1.0 : 0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showResult)
                            }
                        } else {
                            // Invisible placeholder to maintain consistent layout
                            Color.clear
                                .frame(height: 60)
                        }
                        
                        Spacer()
                            .frame(height: 50)
                    }
                    .frame(height: 150) // Fixed height for button area
                }
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        .onAppear {
            // Smooth entrance animations
            withAnimation(.easeOut(duration: 0.6)) {
                viewOpacity = 1.0
                wheelScale = 1.0
            }
            
            // Arrow bounces in after wheel
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                arrowScale = 1.0
            }
            
            // Auto-start spinning after entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                spinWheel()
            }
        }
        } // Close else block
    }
    
    private func spinWheel() {
        isSpinning = true
        
        // Always land on gift (index 5)
        let resultIndex = 5  // Gift segment
        selectedDiscount = segments[resultIndex].0
        
        // Segment layout (each is 60°):
        // Index 0 (70%): 0-60°
        // Index 1 (50%): 60-120°
        // Index 2 (No luck): 120-180°
        // Index 3 (60%): 180-240°
        // Index 4 (30%): 240-300°
        // Index 5 (Gift): 300-360°
        
        // With -90° drawing offset, initial visual positions are:
        // 70% is at top (270-330° visual)
        // Gift is at 210-270° visual
        
        // To bring gift (currently at 210-270°) to top (270-330°):
        // Need to rotate clockwise by 60°
        // But we're measuring from segment 0, so it's 5 * 60 = 300°
        
        // Since segment 0 starts at top, to get segment 5 to top:
        // Rotate backwards by 5 segments = -300° or forward by 60°
        let targetRotation = 60.0
        
        // Add multiple full rotations for realistic spin effect
        let spins = 5  // Fixed number for consistency
        let baseRotation = 360.0 * Double(spins) + targetRotation
        
        // First spin with acceleration
        withAnimation(Animation.easeIn(duration: 0.8)) {
            rotation = 360.0  // Quick first rotation
        }
        
        // Main spin with natural deceleration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 2.5)) {
                rotation = baseRotation
            }
        }
        
        // Micro-bounce at the end for realism
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            finalRotation = baseRotation
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.8)) {
                rotation = finalRotation - 3  // Slight back movement
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.9)) {
                    rotation = finalRotation  // Settle to final position
                }
            }
        }
        
        // Show result after spinning completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
            isSpinning = false
            showResult = true
            
            // Haptic feedback when landing
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Show celebration for gift
            if selectedDiscount == "🎁" {
                showCelebration = true
                
                // Additional haptic celebration
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
                
                print("User won: Special gift offer!")
            } else if selectedDiscount != "No luck" {
                print("User won: \(selectedDiscount) discount")
            }
        }
    }
    
    private func randomColor(index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.3, green: 0.8, blue: 0.5),
            .yellow,
            .blue,
            .red,
            .purple,
            .orange,
            .cyan
        ]
        return colors[index % colors.count]
    }
}

struct WheelSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let text: String
    let textColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw segment
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius = min(geometry.size.width, geometry.size.height) / 2
                    
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle - .degrees(90),
                        endAngle: endAngle - .degrees(90),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .fill(color)
                .overlay(
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let radius = min(geometry.size.width, geometry.size.height) / 2
                        
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: startAngle - .degrees(90),
                            endAngle: endAngle - .degrees(90),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
                
                // Add text in the middle of the segment
                let midAngle = (startAngle.radians + endAngle.radians) / 2
                let textRadius = geometry.size.width / 3.2  // Position text closer to outer edge
                let xPosition = geometry.size.width / 2 + cos(midAngle - .pi / 2) * textRadius
                let yPosition = geometry.size.height / 2 + sin(midAngle - .pi / 2) * textRadius
                
                Text(text)
                    .font(.system(size: text == "No luck" ? 16 : text == "🎁" ? 28 : 20, weight: .bold))
                    .foregroundColor(textColor)
                    .rotationEffect(Angle(radians: midAngle))
                    .position(x: xPosition, y: yPosition)
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SpinWheelView_Previews: PreviewProvider {
    static var previews: some View {
        SpinWheelView(
            onContinue: {},
            onDismiss: {}
        )
    }
}