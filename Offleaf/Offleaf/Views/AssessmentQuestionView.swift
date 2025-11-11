//
//  AssessmentQuestionView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct OnboardingProgressBar: View {
    var progress: Double
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green)
                    .frame(width: geometry.size.width * clampedProgress)
            }
        }
    }
}

struct AssessmentQuestionView: View {
    let progress: Double
    @State private var selectedFrequency: CannabisUseFrequency?
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
                        
                        VStack(spacing: 16) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    selectedFrequency = option
                                    smokeFrequencyRaw = option.rawValue
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                            onComplete()
                                        }
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
    }
}

// Additional question views for the assessment
struct AssessmentQuestion2View: View {
    let progress: Double
    @State private var selectedReason: CannabisUseReason?
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
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selectedReason = option
                                primaryUseReasonRaw = option.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                        onComplete()
                                    }
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

struct AssessmentQuestion3View: View {
    let progress: Double
    @State private var spendingAmount: String = ""
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    var onComplete: () -> Void
    var onBack: (() -> Void)?
    
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale.current
        return formatter
    }()
    
    private var amountFormatter: NumberFormatter { Self.amountFormatter }
    private var decimalSeparator: String { amountFormatter.decimalSeparator ?? "." }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    isFocused = false
                }
            
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
                    Text("On average, how much money do you typically spend on cannabis per week?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 50)
                    
                    // Input field
                    HStack(spacing: 8) {
                        Text("$")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 20)
                        
                        TextField("", text: $spendingAmount, prompt: Text("Enter your answer").foregroundColor(.white.opacity(0.4)))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .focused($isFocused)
                            .padding(.trailing, 20)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isFocused = true
                                }
                            }
                            .onChange(of: spendingAmount) { newValue in
                                let sanitized = sanitizedAmount(newValue)
                                if sanitized != newValue {
                                    spendingAmount = sanitized
                                }
                            }
                    }
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(isFocused ? Color.green : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6), lineWidth: isFocused ? 2 : 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white.opacity(0.05))
                            )
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Done button when keyboard is visible
                if isFocused {
                    Button(action: {
                        isFocused = false
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
                
                // Next button - only enabled when an amount is entered
                Button(action: {
                    // Save the weekly spending amount with validation
                    if let amount = amountFormatter.number(from: spendingAmount)?.doubleValue {
                        // Validate reasonable spending range ($0 - $5000 per week)
                        let maxWeeklySpending = 5000.0
                        let validatedAmount = min(max(0, amount), maxWeeklySpending)
                        weeklySpending = validatedAmount
                    }
                    isFocused = false
                    onComplete()
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(!spendingAmount.isEmpty ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(!spendingAmount.isEmpty ? Color.white : Color.gray.opacity(0.3))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .disabled(spendingAmount.isEmpty)
                .padding(.bottom, 50)
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        .onAppear(perform: initializeAmount)
    }
}

private extension AssessmentQuestion3View {
    func initializeAmount() {
        guard spendingAmount.isEmpty, weeklySpending > 0 else { return }
        spendingAmount = amountFormatter.string(from: NSNumber(value: weeklySpending)) ?? ""
    }
    
    func sanitizedAmount(_ value: String) -> String {
        var result = ""
        var hasSeparator = false
        for character in value {
            if character.isWholeNumber {
                result.append(character)
            } else if String(character) == decimalSeparator && !hasSeparator {
                hasSeparator = true
                result.append(character)
            }
        }
        return result
    }
}

struct AssessmentQuestion4View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                timeInvestmentRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion5View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                strongCravingsRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion6View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                lostInterestRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion7View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                concernRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion8View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                guiltRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion9View: View {
    @State private var selectedResponse: AssessmentBinaryResponse?
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
                    
                    VStack(spacing: 16) {
                        ForEach([AssessmentBinaryResponse.yes, .no], id: \.self) { response in
                            Button(action: {
                                selectedResponse = response
                                toleranceRaw = response.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion10View: View {
    @State private var selectedLevel: AssessmentReadinessLevel?
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
                    
                    VStack(spacing: 16) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selectedLevel = option
                                readinessRaw = option.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion11View: View {
    @State private var selectedLevel: AssessmentConfidenceLevel?
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
                    
                    VStack(spacing: 16) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selectedLevel = option
                                confidenceRaw = option.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct AssessmentQuestion12View: View {
    @State private var selectedArea: AssessmentMotivationArea?
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
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selectedArea = option
                                motivationAreaRaw = option.rawValue
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                .padding(.bottom, 50)
            }
        }
    }
}

struct AssessmentQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AssessmentQuestionView(progress: 0.1, onComplete: {})
    }
}
