//
//  LearnView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct LearnView: View {
    @State private var showingDealingWithStress = false
    @State private var showingMindfulBreathing = false
    @State private var showingBuildingHabits = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        LeafLogoView(size: 40)
                        Text("Learn")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Featured Tip Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                            
                            Text("Featured Tip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("The 10-Minute Rule")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("When a craving hits, wait 10 minutes. Most cravings peak and pass within this time. Use breathing exercises or distraction techniques.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.15),
                                        Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    // Learning Modules
                    VStack(spacing: 16) {
                        Button(action: { showingMindfulBreathing = true }) {
                            LearnModuleCard(
                                icon: "heart.fill",
                                title: "Mindful Breathing",
                                subtitle: "Calm your mind",
                                iconColor: Color(red: 0.9, green: 0.3, blue: 0.3)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { showingBuildingHabits = true }) {
                            LearnModuleCard(
                                icon: "target",
                                title: "Building New Habits",
                                subtitle: "Replace old patterns",
                                iconColor: Color(red: 0.3, green: 0.7, blue: 0.4)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { showingDealingWithStress = true }) {
                            LearnModuleCard(
                                icon: "shield.fill",
                                title: "Dealing with Stress",
                                subtitle: "Healthy coping methods",
                                iconColor: Color(red: 0.4, green: 0.6, blue: 0.9)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDealingWithStress) {
            DealingWithStressView()
        }
        .fullScreenCover(isPresented: $showingMindfulBreathing) {
            MindfulBreathingView()
        }
        .fullScreenCover(isPresented: $showingBuildingHabits) {
            BuildingNewHabitsView()
        }
    }
}

struct LearnModuleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}