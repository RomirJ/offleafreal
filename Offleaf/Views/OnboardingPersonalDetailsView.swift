//
//  OnboardingPersonalDetailsView.swift
//  Offleaf
//

import SwiftUI
import UIKit

struct OnboardingPersonalDetailsView: View {
    @State private var userName: String = ""
    @State private var userAge: Int = 25
    @State private var showProgressDots = false
    @State private var showHeader = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showNameField = false
    @State private var showAgeSection = false
    @State private var showDidYouKnow = false
    @State private var showContinueButton = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var continueButtonScale: CGFloat = 1.0
    @FocusState private var focusedField: Field?
    @AppStorage("userName") private var savedUserName = ""
    @AppStorage("userAge") private var savedUserAge = 0
    
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    enum Field {
        case name
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack(spacing: 0) {
                // Header with back button and progress
                HStack {
                    // Back button
                    Button(action: { 
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onBack?() 
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .scaleEffect(buttonScale)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            buttonScale = pressing ? 0.95 : 1.0
                        }
                    })
                    
                    Spacer()
                    
                    // Progress indicator (near the end of onboarding)
                    HStack {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(showProgressDots ? 1 : 0)
                                .opacity(showProgressDots ? 1 : 0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.05), value: showProgressDots)
                        }
                    }
                    
                    Spacer()
                    
                    // Invisible spacer to balance the layout
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Almost there!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                            
                            Text("Let's personalize\nyour experience")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .lineSpacing(2)
                            
                            Text("This helps us tailor Offleaf specifically for you")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 2)
                        }
                        .padding(.top, 5)
                        
                        VStack(spacing: 20) {
                            // Name Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What should we call you?")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextField("", text: $userName, prompt: Text("Enter your name").foregroundColor(.white.opacity(0.3)))
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focusedField, equals: .name)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(
                                                focusedField == .name ? Color.green : Color.white.opacity(0.2),
                                                lineWidth: focusedField == .name ? 2 : 1
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(focusedField == .name ? Color.green.opacity(0.08) : Color.white.opacity(0.05))
                                            )
                                    )
                                    .onSubmit {
                                        focusedField = nil
                                    }
                            }
                            .opacity(showNameField ? 1 : 0)
                            .scaleEffect(showNameField ? 1 : 0.95)
                            
                            // Age Input with Inline Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How old are you?")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                // Inline Age Picker
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.white.opacity(0.05))
                                        )
                                        .frame(height: 150)
                                    
                                    AgePickerView(selectedAge: $userAge)
                                        .frame(height: 150)
                                        .cornerRadius(25)
                                        .clipped()
                                }
                            }
                            .opacity(showAgeSection ? 1 : 0)
                            .offset(y: showAgeSection ? 0 : 30)
                        }
                        .padding(.top, 10)
                        
                        // Fun fact based on age - inside scrollview
                        if userAge > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                Text("Did you know?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                            
                            Text(getMotivationalMessage(for: userAge))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: userAge)
                        }
                        
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Keyboard toolbar or Continue button
                if focusedField == .name {
                    // Done button in keyboard toolbar area
                    VStack {
                        Button(action: {
                            focusedField = nil
                        }) {
                            Text("Done")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black.opacity(0.9))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Continue button when keyboard is hidden
                    VStack(spacing: 12) {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            saveAndContinue()
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.85, blue: 0.45),
                                            Color(red: 0.35, green: 0.75, blue: 0.4)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                        }
                        .scaleEffect(showContinueButton ? continueButtonScale : 0.9)
                        .opacity(showContinueButton ? 1 : 0)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                continueButtonScale = pressing ? 0.97 : 1.0
                            }
                        })
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: focusedField)
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            // Load saved age if available
            if savedUserAge > 0 {
                userAge = savedUserAge
            }
            
            // Trigger entrance animations
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showProgressDots = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showHeader = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                showTitle = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                showSubtitle = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.4)) {
                showNameField = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.5)) {
                showAgeSection = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.7)) {
                showContinueButton = true
            }
            
            if userAge > 0 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6)) {
                    showDidYouKnow = true
                }
            }
        }
        .onChange(of: userAge) { oldValue, newValue in
            if oldValue == 0 && newValue > 0 && !showDidYouKnow {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showDidYouKnow = true
                }
            }
        }
    }
    
    private func saveAndContinue() {
        // Save only if there's valid input
        if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
            savedUserName = userName.trimmingCharacters(in: .whitespaces)
        }
        
        // Save age (already validated by picker)
        if userAge >= 13 && userAge <= 100 {
            savedUserAge = userAge
        }
        
        focusedField = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onComplete()
        }
    }
    
    private func getMotivationalMessage(for age: Int) -> String {
        switch age {
        case 0..<21:
            return "Starting your wellness journey early sets you up for a lifetime of healthy habits. You're making a smart choice!"
        case 21..<30:
            return "Your 20s are the perfect time to build strong, healthy habits that will benefit you for decades to come."
        case 30..<40:
            return "Taking control of your habits now means more energy and focus for your career and personal life."
        case 40..<50:
            return "It's never too late to make positive changes. Your body and mind will thank you for this decision."
        case 50..<65:
            return "Investing in your health now means more quality time with loved ones and pursuing your passions."
        default:
            return "Your commitment to wellness is inspiring. Every day is an opportunity for positive change."
        }
    }
}

struct OnboardingPersonalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPersonalDetailsView(onComplete: {})
            .preferredColorScheme(.dark)
    }
}
