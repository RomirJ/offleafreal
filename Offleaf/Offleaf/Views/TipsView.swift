//
//  TipsView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI
import UIKit

struct Tip: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let category: TipCategory
}

enum TipCategory: String, CaseIterable {
    case cravings = "Manage Cravings"
    case health = "Health & Recovery"
    case lifestyle = "Lifestyle Changes"
    case mindfulness = "Mindfulness"
    
    var icon: String {
        switch self {
        case .cravings: return "flame.fill"
        case .health: return "heart.fill"
        case .lifestyle: return "star.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .cravings: return Color(red: 1, green: 0.4, blue: 0.4)
        case .health: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .lifestyle: return Color(red: 0.4, green: 0.6, blue: 1)
        case .mindfulness: return Color(red: 0.6, green: 0.4, blue: 0.8)
        }
    }
}

struct TipsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: TipCategory? = nil
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var floatingAnimation = false
    @State private var expandedTips: Set<UUID> = []
    
    let tips = [
        // Cravings
        Tip(icon: "timer", iconColor: Color(red: 1, green: 0.7, blue: 0.3), 
            title: "The 10-Minute Rule", 
            description: "When a craving hits, wait 10 minutes before acting on it. Most cravings peak and fade within 3-10 minutes. Use this time to do something else - take a walk, drink water, or practice deep breathing.", 
            category: .cravings),
        
        Tip(icon: "figure.walk", iconColor: Color(red: 0.4, green: 0.7, blue: 1), 
            title: "Change Your Environment", 
            description: "Leave the space where you're experiencing cravings. A change of scenery can reset your mind. Go outside, visit a friend, or simply move to a different room.", 
            category: .cravings),
        
        Tip(icon: "hand.raised.fill", iconColor: Color(red: 1, green: 0.4, blue: 0.4), 
            title: "HALT Check", 
            description: "Ask yourself: Am I Hungry, Angry, Lonely, or Tired? These states often trigger cravings. Address the underlying need instead of using cannabis.", 
            category: .cravings),
        
        // Health & Recovery
        Tip(icon: "bed.double.fill", iconColor: Color(red: 0.5, green: 0.4, blue: 0.8), 
            title: "Prioritize Sleep", 
            description: "Your sleep patterns may be disrupted for 1-2 weeks. Establish a bedtime routine, avoid screens before bed, and consider melatonin supplements (consult your doctor first).", 
            category: .health),
        
        Tip(icon: "drop.fill", iconColor: Color(red: 0.3, green: 0.7, blue: 1), 
            title: "Stay Hydrated", 
            description: "Drink plenty of water to help flush THC from your system. Aim for 8-10 glasses daily. This also helps with headaches and fatigue during withdrawal.", 
            category: .health),
        
        Tip(icon: "figure.run", iconColor: Color(red: 0.3, green: 0.7, blue: 0.4), 
            title: "Exercise Daily", 
            description: "Physical activity releases natural endorphins, improves mood, and helps with sleep. Even 20 minutes of walking makes a difference. It also helps metabolize remaining THC faster.", 
            category: .health),
        
        // Lifestyle Changes
        Tip(icon: "calendar", iconColor: Color(red: 0.9, green: 0.5, blue: 0.2), 
            title: "Create New Routines", 
            description: "Replace smoking times with new activities. If you smoked after work, go to the gym instead. Morning smoker? Try meditation or journaling.", 
            category: .lifestyle),
        
        Tip(icon: "person.2.fill", iconColor: Color(red: 0.4, green: 0.6, blue: 1), 
            title: "Find Sober Friends", 
            description: "Connect with people who support your journey. Join support groups, find new hobbies, or reconnect with old friends who don't use cannabis.", 
            category: .lifestyle),
        
        Tip(icon: "trash.fill", iconColor: Color(red: 1, green: 0.3, blue: 0.3), 
            title: "Remove Triggers", 
            description: "Get rid of all paraphernalia, delete dealer contacts, and unfollow cannabis-related social media. Out of sight, out of mind.", 
            category: .lifestyle),
        
        // Mindfulness
        Tip(icon: "wind", iconColor: Color(red: 0.4, green: 0.8, blue: 0.6), 
            title: "Practice 4-7-8 Breathing", 
            description: "Inhale for 4 counts, hold for 7, exhale for 8. This activates your parasympathetic nervous system, reducing anxiety and cravings naturally.", 
            category: .mindfulness),
        
        Tip(icon: "sparkles", iconColor: Color(red: 0.6, green: 0.4, blue: 0.8), 
            title: "Mindful Observation", 
            description: "When cravings arise, observe them without judgment. Notice where you feel them in your body. Acknowledge them, then let them pass like clouds in the sky.", 
            category: .mindfulness),
        
        Tip(icon: "heart.text.square.fill", iconColor: Color(red: 1, green: 0.4, blue: 0.6), 
            title: "Practice Gratitude", 
            description: "Write down 3 things you're grateful for each day. This rewires your brain for positivity and reduces the desire to escape through substances.", 
            category: .mindfulness)
    ]
    
    var filteredTips: [Tip] {
        if let category = selectedCategory {
            return tips.filter { $0.category == category }
        }
        return tips
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Animated gradient orbs
            TipsBackgroundView(animating: $floatingAnimation)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Hero section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3),
                                                Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.1),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 20)
                                    .scaleEffect(floatingAnimation ? 1.2 : 0.8)
                                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: floatingAnimation)
                                
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 56, weight: .medium))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(floatingAnimation ? 10 : -10))
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Tips for Success")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Evidence-based strategies to help you stay strong")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
                        
                        // Category filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // All tips button
                                CategoryButton(
                                    title: "All Tips",
                                    icon: "square.grid.2x2",
                                    color: Color(red: 0.9, green: 0.7, blue: 0.3),
                                    isSelected: selectedCategory == nil,
                                    action: { selectedCategory = nil }
                                )
                                
                                ForEach(TipCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        color: category.color,
                                        isSelected: selectedCategory == category,
                                        action: { 
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                selectedCategory = category
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .scaleEffect(showContent ? 1 : 0.9)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showContent)
                        
                        // Tips list
                        VStack(spacing: 16) {
                            ForEach(Array(filteredTips.enumerated()), id: \.element.id) { index, tip in
                                TipCard(
                                    tip: tip,
                                    index: index,
                                    showContent: showContent,
                                    isExpanded: expandedTips.contains(tip.id),
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if expandedTips.contains(tip.id) {
                                                expandedTips.remove(tip.id)
                                            } else {
                                                expandedTips.insert(tip.id)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateGradient = true
                showContent = true
                floatingAnimation = true
            }
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.08)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? color.opacity(0.3) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

struct TipCard: View {
    let tip: Tip
    let index: Int
    let showContent: Bool
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tip.iconColor.opacity(0.3),
                                        tip.iconColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(tip.iconColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: tip.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(tip.iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tip.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: tip.category.icon)
                                .font(.system(size: 12))
                            Text(tip.category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(tip.category.color.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if isExpanded {
                    Text(tip.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1) {} onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .scaleEffect(showContent ? 1 : 0.8)
        .opacity(showContent ? 1 : 0)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7)
            .delay(Double(index) * 0.05 + 0.3),
            value: showContent
        )
    }
}

struct TipsBackgroundView: View {
    @Binding var animating: Bool
    
    var body: some View {
        ZStack {
            // Golden wisdom orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3),
                            Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.2),
                            Color(red: 0.7, green: 0.5, blue: 0.1).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 30)
                .position(x: UIScreen.main.bounds.width - 100, y: 200)
                .rotationEffect(.degrees(animating ? 360 : 0))
                .animation(.linear(duration: 90).repeatForever(autoreverses: false), value: animating)
            
            // Green healing orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 25)
                .position(x: 80, y: UIScreen.main.bounds.height - 200)
                .scaleEffect(animating ? 1.3 : 0.7)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animating)
        }
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}
