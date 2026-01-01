//
//  FeaturesBenefitsView.swift
//  Offleaf
//
//  Features benefits screen with plan selection
//

import SwiftUI

struct FeaturesBenefitsView: View {
    @State private var selectedPlan: String = "yearly"  // Changed default to yearly
    @State private var animateFeatures = false
    @State private var buttonPressed = false
    @Binding var isPurchasing: Bool
    var onPurchase: (String) -> Void  // Pass selected plan type for purchase
    var onRestore: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                // Subtle animated background
                AnimatedBackgroundView()
                    .opacity(0.1)
                
                VStack(spacing: 0) {
                    // Header with back and restore buttons
                    HStack {
                        Button(action: onBack) {
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
                    .padding(.top, max(geometry.safeAreaInsets.top - 10, 5))
                    
                    VStack(spacing: 0) {
                        // Content that changes based on selected plan
                        if selectedPlan == "yearly" {
                            // Yearly content - Trial timeline
                            VStack(spacing: 8) {
                                // Title - smaller size
                                Text("Start your 3-day FREE\ntrial to continue.")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(1)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 5)
                                    
                                    // Timeline
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Today
                                        TimelineItemInline(
                                            icon: "lock.open.fill",
                                            iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                                            title: "Today",
                                            description: "Unlock all the app's features like AI calorie scanning and more.",
                                            isActive: true,
                                            showLine: true,
                                            lineColor: Color(red: 0.3, green: 0.8, blue: 0.5)
                                        )
                                        
                                        // In 2 Days
                                        TimelineItemInline(
                                            icon: "bell.fill",
                                            iconColor: Color(red: 0.3, green: 0.8, blue: 0.5),
                                            title: "In 2 Days - Reminder",
                                            description: "We'll send you a reminder that your trial is ending soon.",
                                            isActive: true,
                                            showLine: true,
                                            lineColor: Color.white.opacity(0.2)
                                        )
                                        
                                        // In 3 Days
                                        TimelineItemInline(
                                            icon: "crown.fill",
                                            iconColor: Color.white.opacity(0.5),
                                            title: "In 3 Days - Billing Starts",
                                            description: "You'll be charged on Dec 4, 2025 unless you cancel anytime before.",
                                            isActive: false,
                                            showLine: false,
                                            lineColor: Color.clear
                                        )
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                }
                                .transition(.opacity)
                            } else {
                                // Monthly content - Features list
                                VStack(spacing: 12) {
                                    // Title - reduced size
                                    VStack(spacing: 0) {
                                        Text("Unlock Offleaf to reach")
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("your goals faster.")
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 5)
                                    
                                    // Features list - more spacing for better distribution
                                    VStack(alignment: .leading, spacing: 22) {
                                        FeatureItem(
                                            title: "Easy food scanning",
                                            description: "Track your calories with just a picture",
                                            isAnimated: animateFeatures,
                                            delay: 0.2
                                        )
                                        
                                        FeatureItem(
                                            title: "Get your dream body", 
                                            description: "We keep it simple to make getting results easy",
                                            isAnimated: animateFeatures,
                                            delay: 0.4
                                        )
                                        
                                        FeatureItem(
                                            title: "Track your progress",
                                            description: "Stay on track with personalized insights and smart reminders",
                                            isAnimated: animateFeatures,
                                            delay: 0.6
                                        )
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                }
                                .transition(.opacity)
                            }
                            
                            Spacer(minLength: 25)
                            
                            // Plan selection - same for both views
                            HStack(spacing: 15) {
                                // Monthly plan
                                PlanSelectionCard(
                                    title: "Monthly",
                                    price: "$9.99",
                                    period: "/mo",
                                    isSelected: selectedPlan == "monthly",
                                    showBadge: false,
                                    badgeText: ""
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedPlan = "monthly"
                                    }
                                }
                                
                                // Yearly plan  
                                PlanSelectionCard(
                                    title: "Yearly",
                                    price: "$2.49",
                                    period: "/mo",
                                    isSelected: selectedPlan == "yearly",
                                    showBadge: true,
                                    badgeText: "3 DAYS FREE"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedPlan = "yearly"
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Dynamic text based on selected plan
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: selectedPlan == "yearly" ? 18 : 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                                
                                Text(selectedPlan == "yearly" ? "No Payment Due Now" : "No Commitment - Cancel Anytime")
                                    .font(.system(size: selectedPlan == "yearly" ? 18 : 16, weight: selectedPlan == "yearly" ? .semibold : .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 10)
                            
                            // Start button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonPressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    // Pass the selected plan to trigger purchase
                                    onPurchase(selectedPlan)
                                }
                            }) {
                                Text(selectedPlan == "yearly" ? "Start My 3-Day Free Trial" : "Start My Journey")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(selectedPlan == "yearly" ? .black : .white)
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
                                    .scaleEffect(buttonPressed ? 0.95 : 1.0)
                                    .shadow(
                                        color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(buttonPressed ? 0.6 : 0.3),
                                        radius: buttonPressed ? 15 : 10,
                                        y: buttonPressed ? 8 : 5
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 24)
                            .disabled(isPurchasing)
                            
                            // Pricing disclaimer
                            Text(selectedPlan == "yearly" ? "3 days free, then $29.99 per year ($2.49/mo)" : "Just $9.99 per month")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                        }
                    }
                
                // Loading overlay when purchasing
                if isPurchasing {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.8, blue: 0.5)))
                                .scaleEffect(1.5)
                            
                            Text("Processing...")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.9))
                        )
                    }
                }
            }
        }
        .onAppear {
            animateFeatures = true
            print("DEBUG: FeaturesBenefitsView appeared, selectedPlan = \(selectedPlan)")
        }
    }
}

struct FeatureItem: View {
    let title: String
    let description: String
    let isAnimated: Bool
    let delay: Double
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .opacity(isAnimated ? 1 : 0)
        .offset(x: isAnimated ? 0 : -20)
        .animation(.easeOut(duration: 0.4).delay(delay), value: isAnimated)
    }
}

struct PlanSelectionCard: View {
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    let showBadge: Bool
    let badgeText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if showBadge {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black)
                        )
                        .offset(y: -12)
                        .zIndex(1)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : .black)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(price)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(isSelected ? .white : .black)
                        Text(period)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSelected ? .white.opacity(0.9) : .black.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.top, showBadge ? -5 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.8, blue: 0.5),
                                    Color(red: 0.25, green: 0.7, blue: 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                        )
                        .offset(x: -10, y: -12)
                        .opacity(isSelected ? 1 : 0)
                        .scaleEffect(isSelected ? 1 : 0.5)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected),
                    alignment: .topTrailing
                )
            }
        }
    }
}

struct TimelineItemInline: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isActive: Bool
    let showLine: Bool
    let lineColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Icon and line - more compact
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

struct FeaturesBenefitsView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesBenefitsView(
            isPurchasing: .constant(false),
            onPurchase: { _ in },
            onRestore: {},
            onBack: {}
        )
    }
}