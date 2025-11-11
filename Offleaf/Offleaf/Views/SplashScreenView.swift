//
//  SplashScreenView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    
    var body: some View {
        if isActive {
            OnboardingContainerView()
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}