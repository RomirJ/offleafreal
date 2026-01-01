//
//  SocialProofRatingView.swift
//  Offleaf
//

import SwiftUI
import StoreKit
import UIKit

struct SocialProofRatingView: View {
    struct Testimonial: Identifiable {
        let id = UUID()
        let quote: String
        let name: String
        let handle: String
    }
    
    struct Avatar: Identifiable {
        let id = UUID()
        let imageName: String
    }
    
    @State private var showContent = false
    @State private var currentIndex = 0
    @State private var hasRequestedReview = false
    @Environment(\.requestReview) var requestReview
    
    // Animation states
    @State private var showTitle = false
    @State private var starScales: [CGFloat] = Array(repeating: 0, count: 5)
    @State private var starRotations: [Double] = Array(repeating: 0, count: 5)
    @State private var starGlow = false
    @State private var leafScale: [CGFloat] = [0, 0]
    @State private var leafRotation: [Double] = [-45, 45]
    @State private var showSubtitle = false
    @State private var showAvatars: [Bool] = Array(repeating: false, count: 3)
    @State private var showUserCount = false
    @State private var userCount = 0
    @State private var showTestimonial = false
    @State private var showAction = false
    @State private var showButtons = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var skipButtonOpacity: Double = 0
    @State private var particleOffsets: [CGPoint] = (0..<8).map { _ in CGPoint(x: 0, y: 0) }
    @State private var particleOpacities: [Double] = Array(repeating: 0, count: 8)
    @State private var shimmerOffset: CGFloat = -200
    @State private var backgroundGradientAngle: Double = 0
    @State private var testimonialScale: CGFloat = 0.9
    @State private var glowPulse: CGFloat = 1.0
    
    var onComplete: () -> Void
    
    private let avatarData: [Avatar] = [
        Avatar(imageName: "Avatar1"), // Male with glasses
        Avatar(imageName: "Avatar2"), // Male with arms crossed
        Avatar(imageName: "Avatar3")  // Female smiling
    ]
    
    private let testimonials: [Testimonial] = [
        Testimonial(
            quote: "Offleaf completely transformed my relationship with everyday habits. I finally feel in control of my life.",
            name: "Sarah M.",
            handle: "@sarahm23"
        ),
        Testimonial(
            quote: "The progress tracking and motivational notifications have kept me on track. I haven't relapsed in 3 months!",
            name: "Michael Stevens",
            handle: "@michaels"
        ),
        Testimonial(
            quote: "I was skeptical at first, but Offleaf's panic button feature has helped me resist countless temptations.",
            name: "Tony Coleman",
            handle: "@tcoleman23"
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Animated mesh gradient
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.15, blue: 0.1),
                        Color(red: 0.1, green: 0.2, blue: 0.15)
                    ],
                    startPoint: UnitPoint(x: 0.5 - 0.3 * cos(backgroundGradientAngle * .pi / 180),
                                          y: 0.5 - 0.3 * sin(backgroundGradientAngle * .pi / 180)),
                    endPoint: UnitPoint(x: 0.5 + 0.3 * cos(backgroundGradientAngle * .pi / 180),
                                        y: 0.5 + 0.3 * sin(backgroundGradientAngle * .pi / 180))
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: backgroundGradientAngle)
                
                // Floating particles
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: CGFloat.random(in: 30...60))
                        .offset(x: particleOffsets[index].x, y: particleOffsets[index].y)
                        .opacity(particleOpacities[index])
                        .blur(radius: 3)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 12) {
                        Text("Love Offleaf?")
                            .font(.system(size: 34, weight: .bold))
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
                            .scaleEffect(showTitle ? 1 : 0.5)
                            .opacity(showTitle ? 1 : 0)
                        
                        // Enhanced stars with animations
                        ZStack {
                            // Glow background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.84, blue: 0.32).opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 250, height: 60)
                                .scaleEffect(glowPulse)
                                .opacity(starGlow ? 0.8 : 0)
                            
                            HStack(spacing: 6) {
                                // Left leaf
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.85, blue: 0.45),
                                                Color(red: 0.25, green: 0.75, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(leafScale[0])
                                    .rotationEffect(.degrees(leafRotation[0]))
                                    .shadow(color: Color(red: 0.25, green: 0.75, blue: 0.4).opacity(0.5), radius: 5)
                                
                                // Animated stars
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 1.0, green: 0.9, blue: 0.4),
                                                        Color(red: 1.0, green: 0.84, blue: 0.32)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .font(.system(size: 28))
                                            .scaleEffect(starScales[index])
                                            .rotationEffect(.degrees(starRotations[index]))
                                            .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.32).opacity(0.6), radius: 8)
                                    }
                                }
                                
                                // Right leaf
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.85, blue: 0.45),
                                                Color(red: 0.25, green: 0.75, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(leafScale[1])
                                    .rotationEffect(.degrees(leafRotation[1]))
                                    .shadow(color: Color(red: 0.25, green: 0.75, blue: 0.4).opacity(0.5), radius: 5)
                            }
                        }
                        
                        Text("This app was designed for people like you.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .opacity(showSubtitle ? 1 : 0)
                            .offset(y: showSubtitle ? 0 : 10)
                        
                        // Enhanced user avatars
                        HStack(spacing: -12) {
                            ForEach(Array(avatarData.enumerated()), id: \.element.id) { index, avatar in
                                ZStack {
                                    // Try to load image, fallback to colored circle with initials
                                    if let uiImage = UIImage(named: avatar.imageName) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                    } else {
                                        // Fallback to initials
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        [Color(red: 0.5, green: 0.3, blue: 0.7),
                                                         Color(red: 0.3, green: 0.6, blue: 0.8),
                                                         Color(red: 0.6, green: 0.4, blue: 0.3)][index],
                                                        [Color(red: 0.5, green: 0.3, blue: 0.7),
                                                         Color(red: 0.3, green: 0.6, blue: 0.8),
                                                         Color(red: 0.6, green: 0.4, blue: 0.3)][index].opacity(0.7)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 42, height: 42)
                                        
                                        Text(["SM", "MS", "TC"][index])
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.5),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                        .frame(width: 42, height: 42)
                                }
                                .scaleEffect(showAvatars[index] ? 1 : 0)
                                .opacity(showAvatars[index] ? 1 : 0)
                                .zIndex(Double(3 - index))
                            }
                            
                            Text("+ \(userCount.formatted()) people")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 20)
                                .opacity(showUserCount ? 1 : 0)
                                .scaleEffect(showUserCount ? 1 : 0.8)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    // Testimonials Section
                    VStack(spacing: 16) {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(testimonials.enumerated()), id: \.element.id) { index, testimonial in
                                TestimonialCard(
                                    testimonial: testimonial,
                                    isVisible: showTestimonial && index == currentIndex
                                )
                                .padding(.horizontal, 20)
                                .tag(index)
                                .scaleEffect(index == currentIndex ? testimonialScale : 0.9)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 180)
                        .opacity(showTestimonial ? 1 : 0)
                        .onChange(of: currentIndex) { _, newValue in
                            // Haptic feedback on swipe
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            // Bounce animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                testimonialScale = 1.05
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.1)) {
                                testimonialScale = 1.0
                            }
                        }
                        
                        // Page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<testimonials.count, id: \.self) { idx in
                                Capsule()
                                    .fill(idx == currentIndex ? 
                                          Color.white : Color.white.opacity(0.3))
                                    .frame(width: idx == currentIndex ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                            }
                        }
                        .opacity(showTestimonial ? 1 : 0)
                    }
                    
                    // Action Section
                    VStack(spacing: 12) {
                        Text("It's Time to Take Action")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color(red: 0.95, green: 0.95, blue: 0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(showAction ? 1 : 0)
                            .scaleEffect(showAction ? 1 : 0.8)
                        
                        Text("Join thousands who've transformed\ntheir health with Offleaf")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .opacity(showAction ? 1 : 0)
                            .offset(y: showAction ? 0 : 10)
                        
                        VStack(spacing: 10) {
                            // Enhanced main CTA button
                            Button(action: {
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                // Success animation
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 1.1
                                    
                                    // Star burst animation
                                    for i in 0..<5 {
                                        starScales[i] = 1.3
                                        starRotations[i] = 360
                                    }
                                }
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)) {
                                    buttonScale = 1.0
                                    for i in 0..<5 {
                                        starScales[i] = 1.0
                                        starRotations[i] = 0
                                    }
                                }
                                
                                if !hasRequestedReview {
                                    hasRequestedReview = true
                                    DispatchQueue.main.async {
                                        requestReview()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        onComplete()
                                    }
                                } else {
                                    onComplete()
                                }
                            }) {
                                ZStack {
                                    // Shimmer effect
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0),
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 100)
                                    .offset(x: shimmerOffset)
                                    .mask(
                                        RoundedRectangle(cornerRadius: 28)
                                    )
                                    
                                    HStack(spacing: 8) {
                                        Text("Rate Offleaf")
                                            .font(.system(size: 19, weight: .bold))
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 17, weight: .bold))
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.45, green: 0.9, blue: 0.5),
                                                Color(red: 0.35, green: 0.8, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(29)
                                    .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4),
                                           radius: 15, x: 0, y: 8)
                                }
                            }
                            .padding(.horizontal, 24)
                            .scaleEffect(buttonScale)
                            .opacity(showButtons ? 1 : 0)
                            .offset(y: showButtons ? 0 : 20)
                            
                            // Skip option with fade in
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                onComplete()
                            }) {
                                Text("Maybe Later")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.vertical, 8)
                            }
                            .opacity(skipButtonOpacity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start background animation
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            backgroundGradientAngle = 360
        }
        
        // Title animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            showTitle = true
        }
        
        // Leaf animations
        for i in 0..<2 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3 + Double(i) * 0.1)) {
                leafScale[i] = 1.0
            }
            
            // Gentle rotation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                leafRotation[i] = i == 0 ? -35 : 35
            }
        }
        
        // Star animations - staggered entrance
        for i in 0..<5 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.4 + Double(i) * 0.08)) {
                starScales[i] = 1.0
                starRotations[i] = Double.random(in: -10...10)
            }
        }
        
        // Star glow
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            starGlow = true
        }
        
        // Pulse animation for glow
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1)) {
            glowPulse = 1.2
        }
        
        // Continuous star twinkle
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            let randomStar = Int.random(in: 0..<5)
            withAnimation(.easeInOut(duration: 0.3)) {
                starScales[randomStar] = 1.2
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.15)) {
                starScales[randomStar] = 1.0
            }
        }
        
        // Subtitle
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            showSubtitle = true
        }
        
        // Avatar animations
        for i in 0..<3 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(1.0 + Double(i) * 0.1)) {
                showAvatars[i] = true
            }
        }
        
        // User count animation
        withAnimation(.easeOut(duration: 0.5).delay(1.3)) {
            showUserCount = true
        }
        
        // Count up animation
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if userCount < 20000 {
                userCount += 523
                if userCount > 20000 {
                    userCount = 20000
                    timer.invalidate()
                }
            }
        }
        
        // Testimonial
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.5)) {
            showTestimonial = true
            testimonialScale = 1.0
        }
        
        // Action section
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.8)) {
            showAction = true
        }
        
        // Buttons
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(2.0)) {
            showButtons = true
        }
        
        // Skip button fade in
        withAnimation(.easeOut(duration: 0.5).delay(2.3)) {
            skipButtonOpacity = 1.0
        }
        
        // Shimmer animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(2.5)) {
            shimmerOffset = 400
        }
        
        // Particle animations
        for i in 0..<8 {
            let delay = Double(i) * 0.2
            let startX = CGFloat.random(in: -150...150)
            let startY = CGFloat.random(in: 200...400)
            
            withAnimation(.easeOut(duration: 1).delay(delay)) {
                particleOpacities[i] = 0.6
            }
            
            withAnimation(.easeInOut(duration: Double.random(in: 8...12)).repeatForever(autoreverses: false).delay(delay)) {
                particleOffsets[i] = CGPoint(
                    x: CGFloat.random(in: -200...200),
                    y: -UIScreen.main.bounds.height - 100
                )
            }
            
            // Set initial position
            particleOffsets[i] = CGPoint(x: startX, y: startY)
        }
        
        // Auto-rotate testimonials
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % testimonials.count
            }
        }
    }
}

private struct TestimonialCard: View {
    let testimonial: SocialProofRatingView.Testimonial
    let isVisible: Bool
    
    @State private var quotesScale: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Stars with animation
            HStack(spacing: 3) {
                ForEach(0..<5) { index in
                    Image(systemName: "star.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.35),
                                    Color(red: 1.0, green: 0.84, blue: 0.32)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .font(.system(size: 16))
                        .scaleEffect(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isVisible)
                }
            }
            
            // Quote with animated quotes
            ZStack(alignment: .topLeading) {
                Text("\"\(testimonial.quote)\"")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.95))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            
            // Author info
            VStack(alignment: .leading, spacing: 2) {
                Text(testimonial.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text(testimonial.handle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Glass morphism effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct SocialProofRatingView_Previews: PreviewProvider {
    static var previews: some View {
        SocialProofRatingView(onComplete: {})
            .preferredColorScheme(.dark)
    }
}