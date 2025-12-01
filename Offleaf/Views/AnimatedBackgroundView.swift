//
//  AnimatedBackgroundView.swift
//  Offleaf
//
//  Simple starfield that actually works
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Solid dark background
            Color.black
                .ignoresSafeArea()
            
            // Static stars as a base layer (always visible)
            ForEach(0..<200, id: \.self) { index in
                Star(
                    index: index,
                    totalStars: 200,
                    animationProgress: animationProgress
                )
            }
            
            // Animated floating particles
            ForEach(0..<50, id: \.self) { index in
                FloatingParticle(
                    index: index,
                    animationProgress: animationProgress
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                animationProgress = 1
            }
        }
    }
}

struct Star: View {
    let index: Int
    let totalStars: Int
    let animationProgress: Double
    
    // Random but consistent properties based on index
    var randomX: CGFloat {
        let seed = Double(index * 7) / Double(totalStars)
        return CGFloat(seed.truncatingRemainder(dividingBy: 1.0))
    }
    
    var randomY: CGFloat {
        let seed = Double(index * 13) / Double(totalStars)
        return CGFloat(seed.truncatingRemainder(dividingBy: 1.0))
    }
    
    var size: CGFloat {
        let seed = Double(index * 3) / Double(totalStars)
        let normalized = seed.truncatingRemainder(dividingBy: 1.0)
        if normalized < 0.3 {
            return 1.0  // Small stars
        } else if normalized < 0.7 {
            return 1.5  // Medium stars
        } else {
            return 2.5  // Large stars
        }
    }
    
    var opacity: Double {
        let seed = Double(index * 5) / Double(totalStars)
        let base = 0.3 + (seed.truncatingRemainder(dividingBy: 1.0) * 0.7)
        
        // Twinkle effect
        let twinkleSpeed = 2.0 + Double(index % 5)
        let twinkle = sin(animationProgress * .pi * 2 * twinkleSpeed + Double(index)) * 0.3 + 0.7
        
        return base * twinkle
    }
    
    var color: Color {
        let seed = Double(index * 11) / Double(totalStars)
        let normalized = seed.truncatingRemainder(dividingBy: 1.0)
        
        if normalized < 0.7 {
            // White/pale green trichomes
            return Color(red: 0.9, green: 0.95, blue: 0.9)
        } else if normalized < 0.9 {
            // Pure white
            return Color.white
        } else {
            // Amber/golden
            return Color(red: 1.0, green: 0.9, blue: 0.5)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .opacity(opacity)
                .position(
                    x: randomX * geometry.size.width,
                    y: randomY * geometry.size.height
                )
                .blur(radius: size < 1.5 ? 0.2 : 0)
        }
    }
}

struct FloatingParticle: View {
    let index: Int
    let animationProgress: Double
    
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color(red: 0.8, green: 0.9, blue: 0.8))
                .frame(width: 1.5, height: 1.5)
                .opacity(0.6)
                .position(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: (CGFloat(index) * 20 + yOffset).truncatingRemainder(dividingBy: geometry.size.height)
                )
                .onAppear {
                    withAnimation(.linear(duration: Double.random(in: 20...40)).repeatForever(autoreverses: false)) {
                        yOffset = geometry.size.height * 2
                    }
                }
        }
    }
}

struct AnimatedBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedBackgroundView()
    }
}