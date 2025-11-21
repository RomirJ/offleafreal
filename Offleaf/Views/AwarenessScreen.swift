//
//  AwarenessScreen.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct AwarenessScreen: View {
    @State private var showCard1 = false
    @State private var showCard2 = false
    @State private var showCard3 = false
    @State private var showButton = false
    var onComplete: () -> Void
    
    let infoCards = [
        (number: "1", text: "Heavy cannabis use can cause brain fog, memory issues, and low motivation."),
        (number: "2", text: "Smoking weed can damage lungs, reduce stamina, and drain energy."),
        (number: "3", text: "Frequent cannabis use can strain relationships and cause financial loss.")
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.35, blue: 0.35),
                    Color(red: 0.85, green: 0.25, blue: 0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("Heavy cannabis use over time has harmful impacts")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 100)
                
                Spacer().frame(height: 50)
                
                // Info cards
                VStack(spacing: 20) {
                    if showCard1 {
                        InfoCard(number: infoCards[0].number, text: infoCards[0].text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    if showCard2 {
                        InfoCard(number: infoCards[1].number, text: infoCards[1].text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    if showCard3 {
                        InfoCard(number: infoCards[2].number, text: infoCards[2].text)
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
                        Text("Life Ahead")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.93, green: 0.35, blue: 0.35))
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

struct InfoCard: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.93, green: 0.35, blue: 0.35))
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
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct AwarenessScreen_Previews: PreviewProvider {
    static var previews: some View {
        AwarenessScreen(onComplete: {})
    }
}