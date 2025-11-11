//
//  OnboardingPersonalDetailsView.swift
//  Offleaf
//

import SwiftUI

struct OnboardingPersonalDetailsView: View {
    @State private var userName: String = ""
    @State private var userAge: String = ""
    @FocusState private var focusedField: Field?
    @AppStorage("userName") private var savedUserName = ""
    @AppStorage("userAge") private var savedUserAge = 0
    
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    enum Field {
        case name
        case age
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
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Progress indicator (near the end of onboarding)
                    HStack {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Invisible spacer to balance the layout
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        // Header
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Almost there!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                            
                            Text("Let's personalize\nyour experience")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                            
                            Text("This helps us tailor Offleaf specifically for you")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 4)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 24) {
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
                                        focusedField = .age
                                    }
                            }
                            
                            // Age Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How old are you?")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextField("", text: $userAge, prompt: Text("Enter your age").foregroundColor(.white.opacity(0.3)))
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .age)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(
                                                focusedField == .age ? Color.green : Color.white.opacity(0.2),
                                                lineWidth: focusedField == .age ? 2 : 1
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(focusedField == .age ? Color.green.opacity(0.08) : Color.white.opacity(0.05))
                                            )
                                    )
                                    .onChange(of: userAge) { newValue in
                                        // Only allow numbers and validate age range
                                        let filtered = newValue.filter { $0.isNumber }
                                        
                                        // Limit to reasonable age range (13-120)
                                        if let age = Int(filtered) {
                                            if age > 120 {
                                                userAge = "120"
                                            } else if filtered.count > 3 {
                                                userAge = String(filtered.prefix(3))
                                            } else {
                                                userAge = filtered
                                            }
                                        } else if filtered != newValue {
                                            userAge = filtered
                                        }
                                    }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Fun fact based on age
                        if let age = Int(userAge), age > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green)
                                    Text("Did you know?")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                                
                                Text(getMotivationalMessage(for: age))
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
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: age)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Continue button
                VStack(spacing: 12) {
                    Button(action: {
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
                    
                    // Skip option shown when fields are empty
                    if userName.isEmpty && userAge.isEmpty {
                        Button(action: {
                            onComplete()
                        }) {
                            Text("Skip for now")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            
            // Done button for number pad
            if focusedField == .age {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        focusedField = nil
                    }) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.3, green: 0.7, blue: 0.4))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: focusedField)
    }
    
    private func saveAndContinue() {
        // Save only if there's valid input
        if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
            savedUserName = userName.trimmingCharacters(in: .whitespaces)
        }
        
        // Validate age is in acceptable range (13-120)
        if let age = Int(userAge), age >= 13 && age <= 120 {
            savedUserAge = age
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
