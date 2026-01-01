//
//  BuildingNewHabitsView.swift
//  Offleaf
//
//  Created by Assistant on 10/19/25.
//

import SwiftUI

struct BuildingNewHabitsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection: String? = nil
    @State private var animateChart = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 16)
                    
                    LeafLogoView(size: 56)
                    
                    Text("Learn")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Title
                        VStack(spacing: 12) {
                            Text("Building New Habits")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Rewire your brain, reclaim your life")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                        
                        // The Habit Loop Infographic
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                                
                                Text("The Habit Loop")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Cannabis hijacks your brain's reward system. Here's how to take it back:")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                            
                            // Circular Habit Loop Visualization
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                                    .frame(width: 280, height: 280)
                                
                                // Three segments
                                ForEach(0..<3) { index in
                                    let angle = Double(index) * 120 - 90
                                    let component = habitLoopComponents[index]
                                    
                                    VStack(spacing: 4) {
                                        ZStack {
                                            Circle()
                                                .fill(component.color.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: component.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(component.color)
                                        }
                                        
                                        Text(component.title)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text(component.subtitle)
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.6))
                                            .multilineTextAlignment(.center)
                                            .frame(width: 80)
                                    }
                                    .offset(
                                        x: cos(angle * .pi / 180) * 100,
                                        y: sin(angle * .pi / 180) * 100
                                    )
                                }
                                
                                // Center text
                                VStack(spacing: 4) {
                                    Text("BREAK")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.white)
                                    Text("THE")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("LOOP")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.white)
                                }
                                
                                // Animated arrows
                                ForEach(0..<3) { index in
                                    let startAngle = Double(index) * 120 - 50
                                    let endAngle = startAngle + 60
                                    
                                    Path { path in
                                        path.addArc(
                                            center: CGPoint(x: 140, y: 140),
                                            radius: 100,
                                            startAngle: .degrees(startAngle),
                                            endAngle: .degrees(endAngle),
                                            clockwise: false
                                        )
                                    }
                                    .stroke(
                                        Color.white.opacity(0.3),
                                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
                                    )
                                    .frame(width: 280, height: 280)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                        
                        // Timeline Infographic
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                
                                Text("The 66-Day Journey")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // Progress bar visualization
                            VStack(spacing: 20) {
                                // Timeline
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 16)
                                    
                                    // Progress segments
                                    HStack(spacing: 0) {
                                        // Week 1-3 (Days 1-21)
                                        Rectangle()
                                            .fill(Color(red: 0.9, green: 0.3, blue: 0.3))
                                            .frame(width: animateChart ? 70 : 0, height: 16)
                                        
                                        // Week 4-9 (Days 22-66)
                                        Rectangle()
                                            .fill(Color(red: 0.9, green: 0.7, blue: 0.3))
                                            .frame(width: animateChart ? 150 : 0, height: 16)
                                        
                                        // Week 10+ (Days 67+)
                                        Rectangle()
                                            .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                                            .frame(width: animateChart ? 60 : 0, height: 16)
                                    }
                                    .animation(.easeInOut(duration: 1.5), value: animateChart)
                                    .cornerRadius(8)
                                }
                                
                                // Milestones
                                VStack(spacing: 16) {
                                    MilestoneRow(
                                        day: "Day 1-21",
                                        phase: "Honeymoon Phase",
                                        description: "High motivation, conscious effort required",
                                        color: Color(red: 0.9, green: 0.3, blue: 0.3),
                                        icon: "flame.fill"
                                    )
                                    
                                    MilestoneRow(
                                        day: "Day 22-66",
                                        phase: "The Grind",
                                        description: "Building neural pathways, consistency crucial",
                                        color: Color(red: 0.9, green: 0.7, blue: 0.3),
                                        icon: "hammer.fill"
                                    )
                                    
                                    MilestoneRow(
                                        day: "Day 67+",
                                        phase: "Automation",
                                        description: "Habit becomes second nature",
                                        color: Color(red: 0.3, green: 0.7, blue: 0.4),
                                        icon: "checkmark.seal.fill"
                                    )
                                }
                            }
                            .onAppear {
                                withAnimation {
                                    animateChart = true
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                        
                        // Replacement Habits Grid
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Smart Habit Swaps")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                            
                            Text("Replace cannabis rituals with these dopamine-boosting alternatives:")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 24)
                            
                            // Grid of habit swaps
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(habitSwaps, id: \.old) { swap in
                                    HabitSwapCard(swap: swap)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Success Formula
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "function")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
                                
                                Text("The Success Formula")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // Formula visualization
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    FormulaComponent(
                                        title: "CUE",
                                        subtitle: "Time/Place",
                                        color: Color(red: 0.4, green: 0.6, blue: 1)
                                    )
                                    
                                    Text("+")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    FormulaComponent(
                                        title: "ROUTINE",
                                        subtitle: "New Habit",
                                        color: Color(red: 0.9, green: 0.7, blue: 0.3)
                                    )
                                    
                                    Text("+")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    FormulaComponent(
                                        title: "REWARD",
                                        subtitle: "Feel Good",
                                        color: Color(red: 0.3, green: 0.7, blue: 0.4)
                                    )
                                }
                                
                                Text("=")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text("LASTING CHANGE")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                                        Color(red: 0.25, green: 0.6, blue: 0.35)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // Common Pitfalls
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                
                                Text("Avoid These Mistakes")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                PitfallRow(text: "Going too big too fast - start with 2 minutes")
                                PitfallRow(text: "Not tracking progress - what gets measured gets done")
                                PitfallRow(text: "No accountability - share your journey")
                                PitfallRow(text: "All-or-nothing thinking - progress over perfection")
                                PitfallRow(text: "Ignoring triggers - plan for weak moments")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Data
let habitLoopComponents = [
    (title: "CUE", subtitle: "Trigger moment", icon: "bell.fill", color: Color(red: 0.4, green: 0.6, blue: 1)),
    (title: "CRAVING", subtitle: "Desire for relief", icon: "brain.head.profile", color: Color(red: 0.9, green: 0.3, blue: 0.3)),
    (title: "RESPONSE", subtitle: "The habit", icon: "arrow.forward.circle.fill", color: Color(red: 0.9, green: 0.7, blue: 0.3))
]

let habitSwaps = [
    (old: "Wake & Bake", new: "Morning Meditation", icon: "sun.max.fill", color: Color(red: 0.9, green: 0.7, blue: 0.3)),
    (old: "Stress Smoking", new: "5-Min Walk", icon: "figure.walk", color: Color(red: 0.3, green: 0.7, blue: 0.4)),
    (old: "Social Smoking", new: "Deep Conversation", icon: "bubble.left.and.bubble.right.fill", color: Color(red: 0.4, green: 0.6, blue: 1)),
    (old: "Boredom Smoking", new: "Creative Project", icon: "paintbrush.fill", color: Color(red: 0.9, green: 0.3, blue: 0.4)),
    (old: "Evening Wind-Down", new: "Hot Bath/Tea", icon: "cup.and.saucer.fill", color: Color(red: 0.7, green: 0.4, blue: 0.9)),
    (old: "Gaming Enhancement", new: "Cold Water Splash", icon: "drop.fill", color: Color(red: 0.3, green: 0.8, blue: 0.8))
]

// Components
struct MilestoneRow: View {
    let day: String
    let phase: String
    let description: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(day)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text(phase)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

struct HabitSwapCard: View {
    let swap: (old: String, new: String, icon: String, color: Color)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(swap.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: swap.icon)
                    .font(.system(size: 22))
                    .foregroundColor(swap.color)
            }
            
            VStack(spacing: 4) {
                Text(swap.old)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .strikethrough()
                
                Image(systemName: "arrow.down")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                
                Text(swap.new)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(swap.color)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(swap.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct FormulaComponent: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PitfallRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("✕")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct BuildingNewHabitsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingNewHabitsView()
    }
}