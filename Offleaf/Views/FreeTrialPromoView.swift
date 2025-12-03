//
//  FreeTrialPromoView.swift
//  Offleaf
//
//  Free trial promotional screen with phone mockup
//

import SwiftUI

struct FreeTrialPromoView: View {
    @State private var phoneScale: CGFloat = 0.9
    @State private var phoneOpacity: Double = 0
    @State private var buttonPressed = false
    var onContinue: () -> Void
    var onRestore: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                // Subtle animated background
                AnimatedBackgroundView()
                    .opacity(0.2)
                
                VStack(spacing: 0) {
                    // Header with restore button
                    HStack {
                        Color.clear
                            .frame(width: 44, height: 44)
                        
                        Spacer()
                        
                        Button(action: onRestore) {
                            Text("Restore")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, max(geometry.safeAreaInsets.top - 10, 10))
                    
                    VStack(spacing: 10) {
                        // Title
                        VStack(spacing: 0) {
                            Text("We want you to")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("try Offleaf for free.")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                            
                        // Phone mockup with app screenshot
                        ZStack {
                            // White glow background
                            RoundedRectangle(cornerRadius: 33)
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 250, height: 450)
                                .blur(radius: 15)
                            
                            // Phone frame
                            RoundedRectangle(cornerRadius: 33)
                                .fill(Color.black)
                                .frame(width: 240, height: 440)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 33)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 0)
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 15)
                                
                                // Phone screen content with proper padding
                                VStack(spacing: 0) {
                                    // Status bar with proper padding
                                    HStack {
                                        Text("5:48")
                                            .font(.system(size: 14, weight: .semibold))
                                        Spacer()
                                        HStack(spacing: 3) {
                                            Text("SOS")
                                                .font(.system(size: 11))
                                            Image(systemName: "wifi")
                                                .font(.system(size: 12))
                                            Image(systemName: "battery.100")
                                                .font(.system(size: 12))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.top, 12)
                                    .padding(.bottom, 8)
                                    
                                    // App content mockup
                                    VStack(spacing: 12) {
                                        // Welcome header
                                        HStack(spacing: 4) {
                                            Image(systemName: "leaf.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                            Text("Welcome, Bob!")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.orange)
                                                Text("0")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        
                                        // Seedling card
                                        VStack(spacing: 10) {
                                            // Plant stages circles
                                            HStack(spacing: 12) {
                                                PlantStageCircle(icon: "🌱", label: "Seedling", isActive: true)
                                                PlantStageCircle(icon: "🌿", label: "Sprout", isActive: false)
                                            }
                                            
                                            // Progress dots
                                            HStack(spacing: 4) {
                                                ForEach(0..<10) { index in
                                                    Circle()
                                                        .fill(index == 0 ? Color.white : Color.white.opacity(0.3))
                                                        .frame(width: 6, height: 6)
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            
                                            // Seedling info card
                                            VStack(spacing: 8) {
                                                Text("SEEDLING")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text("Day 0 of 3")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.8))
                                                
                                                Text("3 days to Sprout")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.white.opacity(0.6))
                                                
                                                Text("Your journey begins")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                        }
                                        .padding(.horizontal, 15)
                                        
                                        // Daily Check-In button
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.black)
                                            Text("Daily Ch...")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                                        )
                                        .padding(.horizontal, 15)
                                        
                                        Spacer(minLength: 10)
                                    }
                                    .padding(.top, 5)
                                }
                                .frame(width: 220, height: 420)
                                .background(Color(red: 0.05, green: 0.05, blue: 0.05))
                                .cornerRadius(28)
                                .padding(10)
                            }
                            .scaleEffect(phoneScale)
                            .opacity(phoneOpacity)
                            .onAppear {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                                    phoneScale = 1.0
                                    phoneOpacity = 1.0
                                }
                            }
                            
                            Spacer()
                            
                            // Bottom section
                            VStack(spacing: 12) {
                                // No payment due now with checkmark
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                    
                                    Text("No Payment Due Now")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                            // Try for $0.00 button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonPressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onContinue()
                                }
                            }) {
                                Text("Try for $0.00")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
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
                                    .cornerRadius(27)
                                    .scaleEffect(buttonPressed ? 0.92 : 1.0)
                                    .shadow(
                                        color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(buttonPressed ? 0.6 : 0.3),
                                        radius: buttonPressed ? 15 : 10,
                                        y: buttonPressed ? 8 : 5
                                    )
                            }
                            .padding(.horizontal, 24)
                            
                            // Pricing disclaimer
                            Text("Just $29.99 per year ($2.49/mo)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 15)
                    }
                }
            }
        }
    }
}

struct PlantStageCircle: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 70, height: 70)
                
                if isActive {
                    Image(systemName: "lock")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    Text(icon)
                        .font(.system(size: 36))
                }
            }
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct FreeTrialPromoView_Previews: PreviewProvider {
    static var previews: some View {
        FreeTrialPromoView(
            onContinue: {},
            onRestore: {}
        )
    }
}