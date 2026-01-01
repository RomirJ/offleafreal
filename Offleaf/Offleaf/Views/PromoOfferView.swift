//
//  PromoOfferView.swift
//  Offleaf
//
//  Promotional pricing screen with free trial emphasis
//

import SwiftUI

struct PromoOfferView: View {
    @State private var isAnimating = false
    @State private var bellRotation: Double = 0
    @State private var showFreeTrialPromo = true
    @State private var showTrialTimeline = false
    @Binding var isPurchasing: Bool
    var onPurchase: (String) -> Void  // Pass plan type for purchase
    var onRestore: () -> Void
    
    var body: some View {
        if showFreeTrialPromo {
            FreeTrialPromoView(
                onContinue: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showFreeTrialPromo = false
                    }
                },
                onRestore: onRestore
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        } else if showTrialTimeline {
            FeaturesBenefitsView(
                isPurchasing: $isPurchasing,
                onPurchase: onPurchase,
                onRestore: onRestore,
                onBack: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showTrialTimeline = false
                    }
                }
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        } else {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                // Subtle animated background
                AnimatedBackgroundView()
                    .opacity(0.3)
                
                VStack(spacing: 0) {
                    // Header with back and restore buttons
                    HStack {
                        Button(action: {
                            // Go back to previous screen
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showFreeTrialPromo = true
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Button(action: onRestore) {
                            Text("Restore")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 40) {
                            // Main content
                            VStack(spacing: 60) {
                                // Title and bell icon
                                VStack(spacing: 30) {
                                    Text("We'll send you\na reminder before your\nfree trial ends")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                        .padding(.top, 20)
                                    
                                    // Bell notification icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                            .blur(radius: 20)
                                        
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.white.opacity(0.2))
                                            .overlay(
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Text("1")
                                                            .font(.system(size: 18, weight: .bold))
                                                            .foregroundColor(.white)
                                                    )
                                                    .offset(x: 25, y: -20)
                                            )
                                            .rotationEffect(.degrees(bellRotation))
                                            .animation(
                                                Animation.easeInOut(duration: 0.15)
                                                    .repeatForever(autoreverses: true),
                                                value: bellRotation
                                            )
                                    }
                                }
                                
                                // Spacing before bottom content
                                Spacer(minLength: 50)
                            }
                            
                            // Bottom section
                            VStack(spacing: 25) {
                                // No payment due now with checkmark
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                    
                                    Text("No Payment Due Now")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.bottom, 10)
                                
                                // Continue button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        showTrialTimeline = true
                                    }
                                }) {
                                    Text("Continue for FREE")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.9, green: 0.95, blue: 0.9),
                                                    Color(red: 0.85, green: 0.92, blue: 0.85)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(
                                            color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3),
                                            radius: 20,
                                            y: 10
                                        )
                                }
                                .padding(.horizontal, 24)
                                
                                // Pricing disclaimer
                                Text("Just $29.99 per year ($2.49/mo)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.top, 5)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        .onAppear {
            isAnimating = true
            // Start bell ringing animation
            withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: true)) {
                bellRotation = 5
            }
            // Stop after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    bellRotation = 0
                }
            }
        }
        }
    }
}

struct PromoOfferView_Previews: PreviewProvider {
    static var previews: some View {
        PromoOfferView(
            isPurchasing: .constant(false),
            onPurchase: { _ in },
            onRestore: {}
        )
    }
}