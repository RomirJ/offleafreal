//
//  DailyCheckInView.swift
//  Offleaf
//
//  Created by Assistant on 10/15/25.
//

import SwiftUI

struct DailyCheckInView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var selectedMood: DailyMoodLevel?
    @State private var selectedCraving: CravingIntensity?
    @State private var selectedTriggers: Set<String> = []
    @State private var practicedCoping: Bool? = nil
    @State private var showingCompletion = false
    @State private var progressWidth: CGFloat = 0.25
    @StateObject private var streakManager = StreakManager.shared
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    @AppStorage("checkInDates") private var checkInDatesString = ""
    
    private let moods = DailyMoodLevel.allCases
    private let cravingLevels = CravingIntensity.allCases
    private let maxStoredCheckInDays = 365
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    LeafLogoView(size: 56)
                    
                    Spacer().frame(width: 16)
                    
                    Text("Daily Check-In")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progressWidth, height: 4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: progressWidth)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 24)
                
                // Content based on step
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 1:
                            moodSelectionContent
                        case 2:
                            cravingsContent
                        case 3:
                            triggersContent
                        case 4:
                            copingStrategiesContent
                        default:
                            moodSelectionContent
                        }
                    }
                    .padding(.top, 40)
                }
                
                // Next/Complete button
                Button(action: handleNext) {
                    Text(currentStep == 4 ? "Complete Check-In" : "Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .opacity(canProceed() ? 1 : 0.5)
                }
                .disabled(!canProceed())
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showingCompletion) {
            CheckInCompletionView(onDismiss: {
                showingCompletion = false
                dismiss()
            })
        }
    }
    
    var moodSelectionContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How are you feeling today?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(moods, id: \.self) { mood in
                    MoodButton(
                        level: mood,
                        isSelected: selectedMood == mood,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedMood = mood
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var cravingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Any cravings today?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(cravingLevels, id: \.self) { level in
                    CravingLevelButton(
                        level: level,
                        isSelected: selectedCraving == level,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedCraving = level
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var triggersContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What triggered you today?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach([
                    ("Stress", "bolt.fill"),
                    ("Boredom", "clock.fill"),
                    ("Social Situation", "person.2.fill"),
                    ("Habit", "arrow.clockwise"),
                    ("Nothing specific", "minus.circle")
                ], id: \.0) { trigger, icon in
                    TriggerButton(
                        text: trigger,
                        icon: icon,
                        isSelected: selectedTriggers.contains(trigger),
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if selectedTriggers.contains(trigger) {
                                    selectedTriggers.remove(trigger)
                                } else {
                                    selectedTriggers.insert(trigger)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var copingStrategiesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Did you practice any healthy coping strategies today?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                CopingButton(
                    text: "Yes",
                    isSelected: practicedCoping == true,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            practicedCoping = true
                        }
                    }
                )
                
                CopingButton(
                    text: "No",
                    isSelected: practicedCoping == false,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            practicedCoping = false
                        }
                    }
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    func handleNext() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            if currentStep < 4 {
                currentStep += 1
                progressWidth = CGFloat(currentStep) / 4.0
            } else {
                // Show completion screen
                recordCheckIn()
                // Add a small delay to ensure UI updates properly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingCompletion = true
                }
            }
        }
    }

    func canProceed() -> Bool {
        switch currentStep {
        case 1:
            return selectedMood != nil
        case 2:
            return selectedCraving != nil
        case 3:
            return !selectedTriggers.isEmpty
        case 4:
            return practicedCoping != nil
        default:
            return true
        }
    }
}

extension DailyCheckInView {
    private func recordCheckIn() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        let dayFormatter = DailyCheckInView.dayFormatter

        // Update streak using StreakManager
        streakManager.recordCheckIn()
        
        lastCheckInDateString = formatter.string(from: today)

        // Persist this check-in date for weekly calendars and analytics
        let todayKey = dayFormatter.string(from: today)
        var existingDates = checkInDatesString
            .split(separator: ",")
            .map(String.init)
            .compactMap { day -> (String, Date)? in
                guard let date = dayFormatter.date(from: day) else { return nil }
                return (day, date)
            }

        let insertedNewDate = !existingDates.contains(where: { $0.0 == todayKey })
        existingDates.removeAll { $0.0 == todayKey }
        existingDates.append((todayKey, today))
        existingDates.sort { $0.1 < $1.1 }
        let limitedDates = existingDates.suffix(maxStoredCheckInDays)
        checkInDatesString = limitedDates.map { $0.0 }.joined(separator: ",")
        if insertedNewDate {
        }

        if let mood = selectedMood,
           let craving = selectedCraving,
           let practiced = practicedCoping {
            let entry = DailyCheckInEntry(
                date: Date(),
                mood: mood,
                craving: craving,
                triggers: Array(selectedTriggers).sorted(),
                practicedCoping: practiced
            )
            DailyCheckInStore.append(entry)
            NotificationCenter.default.post(name: .dailyCheckInCompleted, object: nil)
        }
    }
}

private extension DailyCheckInView {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Use local timezone for consistency
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct MoodButton: View {
    let level: DailyMoodLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(level.emoji)
                    .font(.system(size: 28))
                
                Text(level.description)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isSelected ? 
                          Color(red: 0.9, green: 0.5, blue: 0.2) : 
                          Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? 
                            Color.clear : 
                            Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CravingLevelButton: View {
    let level: CravingIntensity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(level.label)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isSelected ? 
                          Color(red: 0.3, green: 0.7, blue: 0.4) : 
                          Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? 
                            Color.clear : 
                            Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TriggerButton: View {
    let text: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .black : .gray)
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isSelected ? 
                          Color(red: 0.3, green: 0.7, blue: 0.4) : 
                          Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? 
                            Color.clear : 
                            Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CopingButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isSelected ? 
                          Color(red: 0.3, green: 0.7, blue: 0.4) : 
                          Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? 
                            Color.clear : 
                            Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DailyCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        DailyCheckInView()
    }
}
