//
//  FindYourBestSelfView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct FindYourBestSelfView: View {
    @State private var showCard1 = false
    @State private var showCard2 = false
    @State private var showCard3 = false
    @State private var showButton = false
    var onComplete: () -> Void
    
    let benefits = [
        (number: "1", text: "Restore your focus and sharpen your memory."),
        (number: "2", text: "Stabilize your mood and feel more balanced."),
        (number: "3", text: "Wake up refreshed and motivated to achieve more.")
    ]
    
    var body: some View {
        ZStack {
            // Black background with gradient overlay
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Subtle gradient overlay at bottom
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
                // Title
                Text("Find Your Best Self")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 100)
                
                Spacer().frame(height: 50)
                
                // Benefit cards
                VStack(spacing: 20) {
                    if showCard1 {
                        BenefitCard(number: benefits[0].number, text: benefits[0].text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    if showCard2 {
                        BenefitCard(number: benefits[1].number, text: benefits[1].text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    if showCard3 {
                        BenefitCard(number: benefits[2].number, text: benefits[2].text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Button
                if showButton {
                    Button(action: onComplete) {
                        Text("My Plan")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
        .onAppear {
            // Animate cards appearing one by one
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                showCard1 = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.0)) {
                showCard2 = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.7)) {
                showCard3 = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(2.5)) {
                showButton = true
            }
        }
    }
}

struct BenefitCard: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Text
            Text(text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                )
        )
    }
}

struct FindYourBestSelfView_Previews: PreviewProvider {
    static var previews: some View {
        FindYourBestSelfView(onComplete: {})
    }
}