//
//  OnboardingScreenView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct OnboardingScreenView: View {
    @State private var showContent = false
    @State private var showArrow = false
    @State private var arrowBounce = false
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Remove Skip button - just add spacing at top
                Spacer()
                    .frame(height: 100)
                
                Spacer()
                
                // Logo and title
                VStack(spacing: 30) {
                    Image("LeafLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
                    
                    Text("OFFLEAF")
                        .font(.system(size: 46, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .tracking(8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                }
                
                Spacer()
                
                // Turn a New Leaf text
                VStack(spacing: 20) {
                    Text("Turn a New Leaf")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                    
                    Text("Take back control and unlock your full potential. Take a self-assessment to personalize your plan")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)
                }
                
                Spacer().frame(height: 40)
                
                // Animated arrow
                VStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.gray.opacity(0.6))
                        .scaleEffect(showArrow ? 1 : 0.5)
                        .opacity(showArrow ? 1 : 0)
                        .offset(y: arrowBounce ? 5 : 0)
                        .animation(
                            showArrow ? 
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                                .default,
                            value: arrowBounce
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.2), value: showArrow)
                }
                
                Spacer().frame(height: 80)
                
                // Build My Plan button
                Button(action: onComplete) {
                    Text("Build My Plan")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showContent)
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            showContent = true
            
            // Delay arrow appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showArrow = true
                
                // Start bounce animation after arrow appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    arrowBounce = true
                }
            }
        }
    }
}

struct OnboardingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreenView(onComplete: {})
    }
}