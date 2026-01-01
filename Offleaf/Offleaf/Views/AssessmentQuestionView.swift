//
//  AssessmentQuestionView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI
import UIKit

struct OnboardingProgressBar: View {
    var progress: Double
    @State private var animatedProgress: Double = 0
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width * animatedProgress)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedProgress)
            }
        }
        .onAppear {
            animatedProgress = clampedProgress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = clampedProgress
            }
        }
    }
}

struct AssessmentQuestionView: View {
    let progress: Double
    @State private var selectedFrequency: CannabisUseFrequency?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 6)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 6)
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    var onComplete: () -> Void
    
    private let options = CannabisUseFrequency.assessmentOptions
    
    var body: some View {
        GeometryReader { geometry in
            let topInset = geometry.safeAreaInsets.top
            let bottomInset = geometry.safeAreaInsets.bottom

            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    OnboardingProgressBar(progress: progress)
                        .frame(height: 4)
                        .padding(.horizontal, 40)
                        .padding(.top, topInset + 20)
                    
                    VStack(alignment: .leading, spacing: 40) {
                        Text("How often do you\ntypically smoke weed?")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 36)
                            .opacity(showQuestion ? 1 : 0)
                            .offset(y: showQuestion ? 0 : 20)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                                Button(action: {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 0.97
                                    }
                                    
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    selectedFrequency = option
                                    smokeFrequencyRaw = option.rawValue
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                            buttonScale[index] = 1.0
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onComplete()
                                    }
                                }) {
                                    Text(option.assessmentLabel)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.9)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 35)
                                                .stroke(
                                                    selectedFrequency == option ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                    lineWidth: selectedFrequency == option ? 2 : 1.5
                                                )
                                                .background(
                                                    selectedFrequency == option ?
                                                    Color.green.opacity(0.15) : Color.clear
                                                )
                                                .cornerRadius(35)
                                        )
                                        .scaleEffect(buttonScale[index])
                                        .opacity(showOptions[index] ? 1 : 0)
                                        .offset(y: showOptions[index] ? 0 : 10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(minHeight: 0)
                    
                }
                .padding(.bottom, max(bottomInset, 40))
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<options.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

// Additional question views for the assessment
struct AssessmentQuestion2View: View {
    let progress: Double
    @State private var selectedReason: CannabisUseReason?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 6)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 6)
    @AppStorage("assessmentPrimaryUseReason") private var primaryUseReasonRaw = ""
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    private let options = CannabisUseReason.selectionOptions
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button, progress bar, and skip
                HStack(spacing: 16) {
                    // Back button
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    OnboardingProgressBar(progress: progress)
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("What is your main reason for using cannabis?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(options.enumerated()), id: \.element) { index, option in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedReason = option
                                primaryUseReasonRaw = option.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(option.displayName)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedReason == option ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedReason == option ? 2 : 1.5
                                            )
                                            .background(
                                                selectedReason == option ?
                                                Color.green.opacity(0.15) : Color.clear
                                            )
                                            .cornerRadius(35)
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            for index in 0..<options.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion3View: View {
    let progress: Double
    @State private var selectedAmount: Int = 30
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button, progress bar, and skip
                HStack(spacing: 16) {
                    // Back button
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    OnboardingProgressBar(progress: progress)
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(spacing: 30) {
                    Text("On average, how much money do you typically spend on cannabis per week?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 50)
                    
                    // Money picker
                    MoneyPickerView(selectedAmount: $selectedAmount)
                        .frame(height: 300)
                }
                
                Spacer()
                
                // Next button
                Button(action: {
                    // Save the weekly spending amount
                    weeklySpending = Double(selectedAmount)
                    onComplete()
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Initialize selectedAmount from saved value
            if weeklySpending > 0 {
                // Round to nearest $5 increment
                selectedAmount = Int(round(weeklySpending / 5) * 5)
            }
        }
    }
}

struct AssessmentQuestion4View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentTimeSpentObtaining") private var timeInvestmentRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button, progress bar, and skip
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
                    
                    // Progress bar (33% for fourth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.33, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Do you spend a lot of your time getting weed, smoking, or recovering from being high?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                timeInvestmentRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion5View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentStrongCravings") private var strongCravingsRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button, progress bar, and skip
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
                    
                    // Progress bar (42% for fifth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.42, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Do you ever have strong urges or cravings to use weed?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                strongCravingsRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion6View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentLostInterest") private var lostInterestRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (50% for sixth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.5, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Have you lost interest in hobbies, sports, or other activities you used to enjoy because you'd rather use weed?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                lostInterestRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion7View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentConcernedLovedOnes") private var concernRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (58% for seventh question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.58, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Have friends or family expressed concern about how much you use?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                concernRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion8View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentFeelsGuilty") private var guiltRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (67% for eighth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.67, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Have you ever felt guilty or worried about your cannabis use?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                guiltRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion9View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 2)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 2)
    @AppStorage("assessmentToleranceIncrease") private var toleranceRaw = AssessmentBinaryResponse.unanswered.rawValue
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (75% for ninth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.75, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Have you noticed you need to use more weed now to get the same high as before?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array([AssessmentBinaryResponse.yes, .no].enumerated()), id: \.element) { index, response in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedResponse = response
                                toleranceRaw = response.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(response.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .fill(selectedResponse == response ? Color.green.opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedResponse == response ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedResponse == response ? 2 : 1.5
                                            )
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            for index in 0..<2 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion10View: View {
    @State private var selectedLevel: AssessmentReadinessLevel?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 5)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 5)
    @AppStorage("assessmentQuitReadinessLevel") private var readinessRaw = ""
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    private let options = AssessmentReadinessLevel.allCases
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (83% for tenth question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.83, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("How ready do you feel to quit using weed?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(options.enumerated()), id: \.element) { index, option in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedLevel = option
                                readinessRaw = option.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(option.displayName)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedLevel == option ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedLevel == option ? 2 : 1.5
                                            )
                                            .background(
                                                selectedLevel == option ?
                                                Color.green.opacity(0.15) : Color.clear
                                            )
                                            .cornerRadius(35)
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            for index in 0..<options.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion11View: View {
    @State private var selectedLevel: AssessmentConfidenceLevel?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 5)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 5)
    @AppStorage("assessmentQuitConfidenceLevel") private var confidenceRaw = ""
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    private let options = AssessmentConfidenceLevel.allCases
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and progress bar
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
                    
                    // Progress bar (92% for eleventh question out of 12)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.92, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("If you decided to quit, how confident are you that you could do it?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(options.enumerated()), id: \.element) { index, option in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedLevel = option
                                confidenceRaw = option.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(option.displayName)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedLevel == option ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedLevel == option ? 2 : 1.5
                                            )
                                            .background(
                                                selectedLevel == option ?
                                                Color.green.opacity(0.15) : Color.clear
                                            )
                                            .cornerRadius(35)
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            // Stagger option appearances
            for index in 0..<options.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestion12View: View {
    @State private var selectedArea: AssessmentMotivationArea?
    @State private var showQuestion = false
    @State private var showOptions: [Bool] = Array(repeating: false, count: 6)
    @State private var buttonScale: [CGFloat] = Array(repeating: 1.0, count: 6)
    @AppStorage("assessmentMotivationArea") private var motivationAreaRaw = ""
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    private let options = AssessmentMotivationArea.allCases
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar (100% for twelfth question)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geometry.size.width, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 40)
                .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Which part of your life do you most want to improve by quitting cannabis?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(options.enumerated()), id: \.element) { index, option in
                            Button(action: {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale[index] = 0.97
                                }
                                
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                selectedArea = option
                                motivationAreaRaw = option.rawValue
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale[index] = 1.0
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onComplete()
                                }
                            }) {
                                Text(option.displayName)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 35)
                                            .stroke(
                                                selectedArea == option ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                                lineWidth: selectedArea == option ? 2 : 1.5
                                            )
                                            .background(
                                                selectedArea == option ?
                                                Color.green.opacity(0.15) : Color.clear
                                            )
                                            .cornerRadius(35)
                                    )
                                    .scaleEffect(buttonScale[index])
                                    .opacity(showOptions[index] ? 1 : 0)
                                    .offset(y: showOptions[index] ? 0 : 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showQuestion = true
            }
            
            for index in 0..<options.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(Double(index) * 0.05 + 0.3)) {
                    if index < showOptions.count {
                        showOptions[index] = true
                    }
                }
            }
        }
    }
}

struct AssessmentQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AssessmentQuestionView(progress: 0.1, onComplete: {})
    }
}
