//
//  TrialTimelineView.swift
//  Offleaf
//
//  3-day free trial timeline screen
//

import SwiftUI

struct TrialTimelineView: View {
    @State private var selectedPlan: String = "yearly"
    @State private var animateTimeline = false
    var onContinue: () -> Void
    var onRestore: () -> Void
    var onBack: (() -> Void)?
    var onPlanChange: ((String) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                // Subtle animated background
                AnimatedBackgroundView()
                    .opacity(0.15)
                
                VStack(spacing: 0) {
                    // Header with back and restore buttons
                    HStack {
                        Button(action: {
                            onBack?()
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
                    .padding(.top, max(geometry.safeAreaInsets.top - 20, 5))
                    
                    VStack(spacing: 0) {
                        // Title - reduced size
                        Text("Start your 3-day FREE\ntrial to continue.")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(1)
                            .padding(.horizontal, 20)
                            .padding(.top, 5)
                            
                            // Timeline - tighter spacing
                            VStack(alignment: .leading, spacing: 0) {
                                // Today
                                TimelineItem(
                                    icon: "lock.open.fill",
                                    iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                                    title: "Today",
                                    description: "Unlock all the app's features like AI calorie scanning and more.",
                                    isActive: true,
                                    showLine: true,
                                    lineColor: Color(red: 0.3, green: 0.8, blue: 0.5)
                                )
                                .opacity(animateTimeline ? 1 : 0)
                                .offset(y: animateTimeline ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(0.2), value: animateTimeline)
                                
                                // In 2 Days
                                TimelineItem(
                                    icon: "bell.fill",
                                    iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                                    title: "In 2 Days - Reminder",
                                    description: "We'll send you a reminder that your trial is ending soon.",
                                    isActive: true,
                                    showLine: true,
                                    lineColor: Color.white.opacity(0.2)
                                )
                                .opacity(animateTimeline ? 1 : 0)
                                .offset(y: animateTimeline ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(0.4), value: animateTimeline)
                                
                                // In 3 Days
                                TimelineItem(
                                    icon: "crown.fill",
                                    iconColor: Color.white.opacity(0.5),
                                    title: "In 3 Days - Billing Starts",
                                    description: "You'll be charged on Dec 4, 2025 unless you cancel anytime before.",
                                    isActive: false,
                                    showLine: false,
                                    lineColor: Color.clear
                                )
                                .opacity(animateTimeline ? 1 : 0)
                                .offset(y: animateTimeline ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(0.6), value: animateTimeline)
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            
                            Spacer(minLength: 15)
                            
                            // Plan selection
                            HStack(spacing: 15) {
                                // Monthly plan
                                PlanCard(
                                    title: "Monthly",
                                    price: "$9.99",
                                    period: "/mo",
                                    isSelected: selectedPlan == "monthly",
                                    showBadge: false
                                ) {
                                    selectedPlan = "monthly"
                                    onPlanChange?("monthly")
                                }
                                
                                // Yearly plan
                                PlanCard(
                                    title: "Yearly",
                                    price: "$2.49",
                                    period: "/mo",
                                    isSelected: selectedPlan == "yearly",
                                    showBadge: true
                                ) {
                                    selectedPlan = "yearly"
                                    onPlanChange?("yearly")
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // No payment due now
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                
                                Text("No Payment Due Now")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 10)
                            
                            // Start trial button
                            Button(action: onContinue) {
                                Text("Start My 3-Day Free Trial")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
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
                                    .cornerRadius(30)
                                    .shadow(
                                        color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3),
                                        radius: 10,
                                        y: 5
                                    )
                            }
                            .padding(.horizontal, 24)
                            
                            // Pricing disclaimer
                            Text("3 days free, then \(selectedPlan == "yearly" ? "$29.99 per year ($2.49/mo)" : "$9.99 per month")")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            animateTimeline = true
        }
    }
}

struct TimelineItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isActive: Bool
    let showLine: Bool
    let lineColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Icon and line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isActive ? iconColor.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isActive ? iconColor : Color.white.opacity(0.3))
                }
                
                if showLine {
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: 2, height: 55)
                        .padding(.top, 3)
                }
            }
            
            // Text content - tighter spacing
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isActive ? .white : .white.opacity(0.5))
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(isActive ? .white.opacity(0.8) : .white.opacity(0.4))
                    .lineSpacing(1)
                
                Spacer(minLength: 8)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    let showBadge: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                if showBadge {
                    Text("3 DAYS FREE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                        )
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    Text(period)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(red: 0.3, green: 0.8, blue: 0.5) : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.1) : Color.clear)
                    )
            )
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    .offset(x: -10, y: -10)
                    .opacity(isSelected ? 1 : 0),
                alignment: .topTrailing
            )
        }
    }
}

struct TrialTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TrialTimelineView(
            onContinue: {},
            onRestore: {}
        )
    }
}