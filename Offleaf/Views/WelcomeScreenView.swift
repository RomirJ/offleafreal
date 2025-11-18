//
//  WelcomeScreenView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct WelcomeScreenView: View {
    @State private var showLogo = false
    @State private var moveLogoUp = false
    @State private var showContent = false
    @State private var showButton = false
    var onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        LeafLogoView(size: 140)
                            .opacity(showLogo ? 1 : 0)
                            .scaleEffect(showLogo ? 1 : 0.6)
                            .offset(y: moveLogoUp ? 0 : geometry.size.height * 0.18)
                        
                        Text("OFFLEAF")
                            .font(.system(size: 46, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .tracking(8)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 12)
                    }
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    VStack(spacing: 18) {
                        Text("Turn a New Leaf")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 16)
                        
                        Text("Take back control and unlock your full potential. Take a self-assessment to personalize your plan.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 16)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 40)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onNext()
                        }
                    }) {
                        Text("Build My Plan")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(bottomInset, 24))
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showLogo = true
            }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.6)) {
                moveLogoUp = true
            }

            withAnimation(.easeOut(duration: 0.45).delay(0.85)) {
                showContent = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(1.1)) {
                showButton = true
            }
        }
    }
}

struct WelcomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreenView(onNext: {})
    }
}
