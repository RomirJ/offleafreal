//
//  ProgressTabView.swift
//  Offleaf
//
//  Created by Assistant on 10/15/25.
//

import SwiftUI
import Combine

struct ProgressTabView: View {
    @StateObject private var streakManager = StreakManager.shared
    @State private var selectedTab: String = "Mood"
    @State private var checkInEntries: [DailyCheckInEntry] = []
    
    // User data from AppStorage
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    @AppStorage("checkInDates") private var checkInDatesString = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    
    private static let isoFormatter = ISO8601DateFormatter()
    
    private static let storageDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Use local timezone for consistency
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // Use unified streak from StreakManager
    private var currentStreak: Int {
        streakManager.currentStreak
    }

    // Match HomeView's daysSinceQuit calculation for consistency
    private var daysSinceQuit: Int {
        guard !quitDateString.isEmpty,
              let quitDate = ProgressTabView.isoFormatter.date(from: quitDateString) else {
            return 0
        }
        let calendar = Calendar.current
        let startOfQuitDate = calendar.startOfDay(for: quitDate)
        let startOfToday = calendar.startOfDay(for: Date())
        
        // If quit date is in the future, treat as 0 days
        if startOfQuitDate > startOfToday {
            return 0
        }
        
        let days = calendar.dateComponents([.day], from: startOfQuitDate, to: startOfToday).day ?? 0
        // Add 1 to start counting from Day 1 on the quit date itself
        return max(1, days + 1)
    }
    
    private var derivedDaysFromQuitDate: Int {
        guard !quitDateString.isEmpty,
              let quitDate = ProgressTabView.isoFormatter.date(from: quitDateString) else {
            return 0
        }
        let days = Calendar.current.dateComponents([.day], from: quitDate, to: Date()).day ?? 0
        return max(0, days)
    }

    private var longestStreak: Int {
        max(streakManager.longestStreak, currentStreak)
    }

    private var totalDays: Int {
        max(streakManager.totalDays, checkInDateStrings.count)
    }

    private var computedLongestStreak: Int {
        let dates = checkInDates
        guard !dates.isEmpty else { return 0 }
        let calendar = Calendar.current
        var longest = 1
        var current = 1

        for index in 1..<dates.count {
            let previous = calendar.startOfDay(for: dates[index - 1])
            let currentDate = calendar.startOfDay(for: dates[index])
            let difference = calendar.dateComponents([.day], from: previous, to: currentDate).day ?? 0

            if difference == 1 {
                current += 1
                longest = max(longest, current)
            } else if difference == 0 {
                continue
            } else {
                current = 1
            }
        }

        return max(longest, current)
    }

    private var checkInDateStrings: [String] {
        checkInDatesString.split(separator: ",").map(String.init)
    }

    private var checkInDates: [Date] {
        let formatter = ProgressTabView.storageDayFormatter
        return checkInDateStrings.compactMap { formatter.date(from: $0) }.sorted()
    }

    // Calculate money saved based on days since quit (not check-in streak)
    private var moneySaved: String {
        let baselineWeeklySpending = 105.0 // $15/day fallback for users without data
        let effectiveSpending = weeklySpending > 0 ? weeklySpending : baselineWeeklySpending
        let dailySpending = effectiveSpending / 7.0
        let totalSaved = dailySpending * Double(daysSinceQuit)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = totalSaved < 100 ? 2 : 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: totalSaved)) ?? "$0"
    }
    
    // Calculate time saved based on days since quit (not check-in streak)
    private var timeSaved: String {
        let frequency = CannabisUseFrequency(storedValue: smokeFrequencyRaw)
        let totalHours = max(0, Double(daysSinceQuit) * frequency.estimatedHoursPerDay)
        
        if totalHours < 24 {
            return "\(Int(totalHours))h"
        }
        let days = Int(totalHours / 24)
        let remainingHours = Int(totalHours.truncatingRemainder(dividingBy: 24))
        if remainingHours == 0 {
            return "\(days)d"
        }
        return "\(days)d \(remainingHours)h"
    }
    
    // Days to next milestone based on days since quit
    private var daysToNextMilestone: Int {
        let milestones = [7, 14, 30, 60, 90, 180, 365]
        for milestone in milestones {
            if daysSinceQuit < milestone {
                return milestone - daysSinceQuit
            }
        }
        return 0
    }

    private static let dayLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private var moodData: [CGFloat] {
        checkInEntries.map { CGFloat($0.mood.score) }
    }

    private var cravingsData: [CGFloat] {
        checkInEntries.map { CGFloat($0.craving.score) }
    }

    private var dayLabels: [String] {
        checkInEntries.map { ProgressTabView.dayLabelFormatter.string(from: $0.date) }
    }
    
    private var nextMilestoneText: String {
        let milestones = [(7, "7-day"), (14, "14-day"), (30, "30-day"), 
                         (60, "60-day"), (90, "90-day"), (180, "6-month"), 
                         (365, "1-year")]
        for (days, name) in milestones {
            if daysSinceQuit < days {
                return "\(days - daysSinceQuit) days to your \(name) badge"
            }
        }
        return "You've achieved all milestones! 🎉"
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    LeafLogoView(size: 56)
                    Text("Progress")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Streak Stats
                        VStack(spacing: 20) {
                            // Longest Streak
                            StatCard(
                                value: "\(longestStreak)",
                                label: "Longest Streak",
                                isLarge: true
                            )
                            
                            // Total Days and Current Streak
                            HStack(spacing: 16) {
                                StatCard(
                                    value: "\(totalDays)",
                                    label: "Total Days",
                                    isLarge: false
                                )
                                
                                StatCard(
                                    value: "\(currentStreak)",
                                    label: "Current Streak",
                                    isLarge: false
                                )
                            }
                            
                            // Time and Money Saved
                            HStack(spacing: 16) {
                                SavedStatCard(
                                    icon: "clock.fill",
                                    title: "Time Saved",
                                    value: timeSaved
                                )
                                
                                SavedStatCard(
                                    icon: "dollarsign.circle.fill",
                                    title: "Money Saved",
                                    value: moneySaved
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Mood/Cravings Chart
                        VStack(spacing: 0) {
                            // Tab Selector
                            HStack(spacing: 20) {
                                ChartTabButton(
                                    title: "Mood",
                                    isSelected: selectedTab == "Mood"
                                ) {
                                    selectedTab = "Mood"
                                }
                                
                                ChartTabButton(
                                    title: "Cravings",
                                    isSelected: selectedTab == "Cravings"
                                ) {
                                    selectedTab = "Cravings"
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 30)
                            
                            // Chart
                            if !moodData.isEmpty || !cravingsData.isEmpty {
                                ChartView(
                                    data: selectedTab == "Mood" ? moodData : cravingsData,
                                    selectedTab: selectedTab
                                )
                                .frame(height: 200)
                                .padding(.horizontal, 24)
                            } else {
                                // Empty state for chart
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    Text("No data yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Track your daily mood and cravings\nto see your progress")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                            }
                            
                            // Days of week - only show if we have data
                            if !moodData.isEmpty || !cravingsData.isEmpty {
                                HStack {
                                    ForEach(dayLabels, id: \.self) { label in
                                        Text(label.uppercased())
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                
                                let scaleDescription = selectedTab == "Mood" ? "Daily mood (1-5)" : "Craving intensity (0-4)"
                                Text(scaleDescription)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            }
                        }
                        
                        // Next Milestone Card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.15))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "dollarsign")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.2))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Next Milestone")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 6) {
                                    Text(nextMilestoneText)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("🏆")
                                        .font(.system(size: 16))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.9, green: 0.5, blue: 0.2).opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        // Extra space to ensure content isn't blocked by I Need Help button
                        Spacer(minLength: 200)
                    }
                }
                .refreshable {
                    // Pull to refresh functionality
                    reconcileStreakIfNeeded()
                    reloadEntries()
                }
            }
        }
        .onAppear {
            reconcileStreakIfNeeded()
            reloadEntries()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dailyCheckInCompleted)) { _ in
            reloadEntries()
        }
    }
}

private extension ProgressTabView {
    func reloadEntries() {
        checkInEntries = DailyCheckInStore.recentEntries(limit: 7)
    }
    
    func reconcileStreakIfNeeded() {
        guard !lastCheckInDateString.isEmpty else {
            // No last check-in, ensure streak is 0 if no check-ins exist
            if checkInDateStrings.isEmpty {
                streakManager.validateStreak()
            }
            return
        }
        
        let formatter = ISO8601DateFormatter()
        guard let lastDate = formatter.date(from: lastCheckInDateString) else { return }
        
        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastDate)
        let today = calendar.startOfDay(for: Date())
        let delta = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        // If more than 1 day has passed since last check-in, reset streak
        if delta > 1 {
            streakManager.validateStreak()
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let isLarge: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: isLarge ? 48 : 36, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isLarge ? 120 : 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SavedStatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ChartTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: 50, height: 3)
                } else {
                    Color.clear
                        .frame(width: 50, height: 3)
                }
            }
        }
    }
}

struct ChartView: View {
    let data: [CGFloat]
    let selectedTab: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Y-axis grid lines
                VStack(spacing: 0) {
                    ForEach(0..<6) { index in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                        if index < 5 {
                            Spacer()
                        }
                    }
                }
                
                // Y-axis labels
                HStack {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("5")
                        Spacer()
                        Text("2")
                        Spacer()
                        Text("1")
                        Spacer()
                        Text("0")
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(width: 20)
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                // Chart line
                HStack {
                    Spacer().frame(width: 30)
                    
                    Path { path in
                        let segments = max(data.count - 1, 1)
                        let spacing = segments > 0 ? (geometry.size.width - 30) / CGFloat(segments) : 0
                        let maxValue: CGFloat = selectedTab == "Mood" ? 5 : 4
                        let chartHeight = geometry.size.height - 20
                        
                        if data.isEmpty {
                            return
                        }

                        for (index, value) in data.enumerated() {
                            let x = CGFloat(index) * spacing
                            let y = chartHeight - (value / max(maxValue, 1) * chartHeight)

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(selectedTab == "Mood" ? Color.white : Color(red: 0.3, green: 0.7, blue: 0.4), lineWidth: 2)
                    
                }
                
                // Data points overlay
                HStack {
                    Spacer().frame(width: 30)
                    
                    GeometryReader { geo in
                        ForEach(0..<data.count, id: \.self) { index in
                            let segments = max(data.count - 1, 1)
                            let spacing = segments > 0 ? (geo.size.width) / CGFloat(segments) : 0
                            let maxValue: CGFloat = selectedTab == "Mood" ? 5 : 4
                            let chartHeight = geo.size.height - 20
                            let x = CGFloat(index) * spacing
                            let y = chartHeight - (data[index] / max(maxValue, 1) * chartHeight)
                            
                            Circle()
                                .fill(index == data.count - 1 ? Color(red: 0.9, green: 0.5, blue: 0.2) : (selectedTab == "Mood" ? Color.white : Color(red: 0.3, green: 0.7, blue: 0.4)))
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
            }
        }
    }
}

struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTabView()
    }
}
