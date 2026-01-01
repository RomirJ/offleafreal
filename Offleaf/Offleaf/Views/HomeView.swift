//
//  HomeView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var streakManager = StreakManager.shared
    @State private var selectedTab = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("justResetCounter") private var justResetCounter = false
    @AppStorage("checkInDates") private var checkInDatesString = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    @State private var isEditingName = false
    @State private var tempName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var timeSaved = "0h"
    @State private var moneySaved = "$0"
    @State private var moneySavedContext = ""
    @State private var showingDailyCheckIn = false
    @State private var showingBreathe = false
    @State private var showingPanicButton = false
    @State private var showingJournal = false
    @State private var showingContacts = false
    @State private var showingTips = false
    
    // Animation states
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var countedDays = 0
    @State private var showResetAnimation = false
    @State private var daysCountTask: Task<Void, Never>? = nil
    
    // Refresh states
    @State private var isRefreshing = false
    
    // Midnight update timer
    @State private var midnightTimer: Timer? = nil
    @State private var currentDate = Date()
    
    // Calendar expansion states
    @State private var calendarExpanded = false
    @State private var currentMonth = Date()
    @Namespace private var calendarNamespace
    
    // Calendar performance optimization
    @State private var cachedMonthDates: [Date?] = []
    @State private var cachedDateCheckStates: [Int: Bool] = [:]
    @State private var isLoadingCalendar = false
    
    // Shared instances for performance
    private static let sharedCalendar = Calendar.current
    private static let swipeThreshold: CGFloat = -30
    
    // Cached formatters for performance
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private static let accessibilityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // Calendar data
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Use local timezone for consistency with Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private var dayFormatter: DateFormatter { Self.dayFormatter }
    
    // Compute current week dates and check status based on quit date
    var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = weekday - 1
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var todayIndex: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return weekday - 1 // Sunday is 1, so subtract 1 for 0-based index
    }
    
    private var checkInDateSet: Set<String> {
        Set(checkInDatesString.split(separator: ",").map(String.init))
    }
    
    var checkedDays: [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        let dates = checkInDateSet
        
        return weekDates.map { date in
            let dayStart = calendar.startOfDay(for: date)
            let dayKey = dayFormatter.string(from: dayStart)
            let isBeforeOrToday = dayStart <= today
            return isBeforeOrToday && dates.contains(dayKey)
        }
    }
    
    // Days clean reflects true check-in streak so UI stays consistent with calendar
    var calculatedDaysClean: Int {
        streakManager.currentStreak
    }
    
    // Total days clean across all time (for cumulative stats)
    var totalDaysClean: Int {
        // Count all unique check-in dates
        checkInDateSet.count
    }
    
    // Days since quit date (for main Days Sober counter)
    var daysSinceQuit: Int {
        guard !quitDateString.isEmpty,
              let quitDate = ISO8601DateFormatter().date(from: quitDateString) else {
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
    
    // Month calendar helpers - optimized with caching
    private func calculateMonthDates() -> [Date?] {
        let calendar = Self.sharedCalendar
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return [] // Return empty array if calendar fails
        }
        let numberOfDays = range.count
        
        // Get the first day of the month's weekday
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1 // 0-based
        
        // Create array with nil padding for empty days at start of month
        var dates: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        // Add all days of the month
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Pad to complete 6 weeks (42 days total) for consistent grid
        while dates.count < 42 {
            dates.append(nil)
        }
        
        return dates
    }
    
    private func updateCalendarCache() {
        isLoadingCalendar = true
        cachedMonthDates = calculateMonthDates()
        
        // Pre-calculate check states for performance
        cachedDateCheckStates.removeAll()
        for (index, date) in cachedMonthDates.enumerated() {
            if let date = date {
                cachedDateCheckStates[index] = isDateCheckedOptimized(date)
            }
        }
        isLoadingCalendar = false
    }
    
    var monthYearString: String {
        return Self.monthYearFormatter.string(from: currentMonth)
    }
    
    // Navigation limits
    var canNavigateToPreviousMonth: Bool {
        // Allow navigation back to quit date or at most 1 year
        let calendar = Self.sharedCalendar
        if let quitDate = ISO8601DateFormatter().date(from: quitDateString) {
            let quitMonth = calendar.startOfDay(for: quitDate)
            let currentMonthStart = calendar.startOfDay(for: currentMonth)
            return currentMonthStart > quitMonth
        }
        // If no quit date, limit to 1 year back
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return currentMonth > oneYearAgo
    }
    
    var canNavigateToNextMonth: Bool {
        // Don't allow navigating beyond current month
        let calendar = Self.sharedCalendar
        let today = Date()
        let currentMonthOfToday = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let selectedMonthStart = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        return selectedMonthStart < currentMonthOfToday
    }
    
    // Optimized helper functions with caching
    func isDateCheckedOptimized(_ date: Date) -> Bool {
        let calendar = Self.sharedCalendar
        let dayStart = calendar.startOfDay(for: date)
        let dayKey = dayFormatter.string(from: dayStart)
        return checkInDateSet.contains(dayKey)
    }
    
    func isDateCheckedCached(at index: Int) -> Bool {
        return cachedDateCheckStates[index] ?? false
    }
    
    func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Self.sharedCalendar.isDateInToday(date)
    }
    
    func isPastDate(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Self.sharedCalendar
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: date)
        return dayStart < today
    }
    
    func isFutureDate(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Self.sharedCalendar
        let today = calendar.startOfDay(for: currentDate)
        let dayStart = calendar.startOfDay(for: date)
        return dayStart > today
    }
    
    // Accessibility helpers
    func getAccessibilityLabel(for date: Date?, at index: Int) -> String {
        guard let date = date else { return "Empty" }
        
        let dateString = Self.accessibilityDateFormatter.string(from: date)
        
        if isToday(date) {
            if isDateCheckedCached(at: index) {
                return "\(dateString), Today, Checked in"
            } else {
                return "\(dateString), Today, Not checked in"
            }
        } else if isPastDate(date) {
            if isDateCheckedCached(at: index) {
                return "\(dateString), Checked in"
            } else {
                return "\(dateString), Missed"
            }
        } else {
            return "\(dateString), Future date"
        }
    }
    
    // Calculate money saved
    var calculatedMoneySaved: (amount: String, context: String, metaphor: String) {
        // Use baseline of $15/day if no spending data provided
        let baselineWeeklySpending = 105.0 // $15 per day * 7 days
        let effectiveSpending = weeklySpending > 0 ? weeklySpending : baselineWeeklySpending
        
        let dailySpending = effectiveSpending / 7.0
        // Use days since quit for cumulative savings
        let totalSaved = dailySpending * Double(daysSinceQuit)
        
        // Format the money
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        let amountString = formatter.string(from: NSNumber(value: totalSaved)) ?? "$0"
        
        // Calculate context (e.g., "6 packs worth")
        let packPrice = 30.0 // Average price per pack/eighth
        let packsWorth = Int(totalSaved / packPrice)
        var context = ""
        
        if weeklySpending == 0 {
            context = "Based on avg user"
        } else if packsWorth == 0 {
            context = "Keep going!"
        } else if packsWorth == 1 {
            context = "1 pack worth"
        } else {
            context = "\(packsWorth) packs worth"
        }
        
        // Create meaningful metaphors for money
        let metaphor: String
        if totalSaved == 0 {
            metaphor = "New beginning"
        } else if totalSaved < 10 {
            metaphor = "≈ A coffee"
        } else if totalSaved < 30 {
            metaphor = "≈ A nice meal"
        } else if totalSaved < 60 {
            metaphor = "≈ Tank of gas"
        } else if totalSaved < 100 {
            metaphor = "≈ Date night"
        } else if totalSaved < 200 {
            metaphor = "≈ New shoes"
        } else if totalSaved < 500 {
            metaphor = "≈ Weekend trip"
        } else if totalSaved < 1000 {
            metaphor = "≈ New phone"
        } else {
            metaphor = "≈ Real savings!"
        }
        
        return (amountString, context, metaphor)
    }
    
    // Calculate time saved based on frequency
    var calculatedTimeSaved: (amount: String, context: String, fullDisplay: String, metaphor: String) {
        // Calculate hours per day based on frequency
        let frequency = CannabisUseFrequency(storedValue: smokeFrequencyRaw)
        // Use days since quit for cumulative time saved
        let totalHours = frequency.estimatedHoursPerDay * Double(daysSinceQuit)
        
        // Create display formats
        let amount: String
        let context: String
        let fullDisplay: String
        let metaphor: String
        
        if totalHours < 24 {
            let hours = Int(totalHours)
            amount = "\(hours)h"
            context = "\(hours) hours gained"
            fullDisplay = hours == 1 ? "1 hour" : "\(hours) hours"
            
            // Create meaningful metaphors
            if hours == 0 {
                metaphor = "Starting fresh"
            } else if hours < 2 {
                metaphor = "≈ A good walk"
            } else if hours < 4 {
                metaphor = "≈ A movie"
            } else if hours < 8 {
                metaphor = "≈ Half a workday"
            } else if hours < 16 {
                metaphor = "≈ A full workday"
            } else {
                metaphor = "≈ A full day awake"
            }
        } else {
            let days = Int(totalHours / 24)
            let remainingHours = Int(totalHours.truncatingRemainder(dividingBy: 24))
            if remainingHours > 0 {
                amount = "\(days)d \(remainingHours)h"
                context = "\(days) days, \(remainingHours) hrs gained"
                fullDisplay = "\(days)d \(remainingHours)h"
                metaphor = days == 1 ? "≈ A weekend day" : "≈ A long weekend"
            } else {
                amount = "\(days)d"
                context = days == 1 ? "1 full day gained" : "\(days) full days gained"
                fullDisplay = days == 1 ? "1 day" : "\(days) days"
                
                if days < 7 {
                    metaphor = "≈ A vacation"
                } else if days < 30 {
                    metaphor = "≈ Weeks of life"
                } else {
                    metaphor = "≈ Months back"
                }
            }
        }
        
        return (amount, context, fullDisplay, metaphor)
    }
    
    // Calculate joints/grams avoided based on spending and frequency
    var calculatedJointsAvoided: (amount: String, context: String, fullDisplay: String, metaphor: String) {
        // Use spending to calculate quantity if available
        let baselineWeeklySpending = 105.0
        let effectiveSpending = weeklySpending > 0 ? weeklySpending : baselineWeeklySpending
        
        // Estimate grams based on spending (avg $10-15 per gram)
        let pricePerGram = 12.5
        let gramsPerWeek = effectiveSpending / pricePerGram
        let gramsPerDay = gramsPerWeek / 7.0
        
        // Convert to joints (0.5g per joint average)
        let jointsPerDay = gramsPerDay / 0.5
        // Use days since quit for cumulative consumption avoided
        let totalJoints = Int(jointsPerDay * Double(daysSinceQuit))
        let totalGrams = gramsPerDay * Double(daysSinceQuit)
        
        // Format the output
        let amount: String
        let context: String
        let fullDisplay: String
        let metaphor: String
        
        if totalJoints < 50 {
            amount = "\(totalJoints)"
            context = "joints avoided"
            fullDisplay = totalJoints == 1 ? "1 joint" : "\(totalJoints) joints"
            
            if totalJoints == 0 {
                metaphor = "Fresh start"
            } else if totalJoints < 7 {
                metaphor = "Clear lungs"
            } else if totalJoints < 14 {
                metaphor = "≈ Week's worth"
            } else if totalJoints < 30 {
                metaphor = "≈ Half month's use"
            } else {
                metaphor = "≈ Month's worth"
            }
        } else {
            let gramsRounded = Int(totalGrams)
            amount = "\(gramsRounded)g"
            context = "\(totalJoints) joints avoided"
            fullDisplay = "\(gramsRounded) grams"
            
            if gramsRounded < 14 {
                metaphor = "≈ Half ounce"
            } else if gramsRounded < 28 {
                metaphor = "≈ An ounce"
            } else if gramsRounded < 56 {
                metaphor = "≈ Two ounces"
            } else {
                metaphor = "≈ Quarter pound+"
            }
        }
        
        return (amount, context, fullDisplay, metaphor)
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab with smooth transitions
            ZStack {
                Color.black // Base black layer
                    .ignoresSafeArea()
                
                TabContentView(selectedTab: selectedTab) {
                    Group {
                        switch selectedTab {
                        case 0:
                            homeContent
                                .background(Color.black)
                        case 1:
                            LearnView()
                                .background(Color.black)
                        case 2:
                            ProgressTabView()
                                .background(Color.black)
                        case 3:
                            ProfileView()
                                .background(Color.black)
                        default:
                            homeContent
                                .background(Color.black)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom stack with emergency button and tab bar
            VStack(spacing: 12) {
                // Floating Emergency Button
                EmergencyHelpButton()
                    .padding(.horizontal, 20)
                
                // Custom floating tab bar
                CustomTabView(selectedTab: $selectedTab)
                    .background(Color.clear)
            }
            
            // Reset Animation Overlay - Plant rebirth theme
            if showResetAnimation {
                ResetAnimationView(isShowing: $showResetAnimation)
            }
            
            // Refresh Animation Overlay - Above everything
            if isRefreshing {
                VStack {
                    RefreshAnimationView()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.95))
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    
                    Spacer()
                }
                .zIndex(200) // Higher than tab bar
                .allowsHitTesting(false)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CounterReset"))) { _ in
            // Delay to ensure view has settled after dismissal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Reset to day 0
                countedDays = 0
                
                // Show reset animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    showResetAnimation = true
                }
                
                // Hide animation after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showResetAnimation = false
                    }
                    // Clear the flag
                    UserDefaults.standard.set(false, forKey: "justResetCounter")
                }
            }
        }
    }
    
    var homeContent: some View {
        ZStack {
            // Animated background with particles and breathing gradients
            AnimatedBackgroundView()
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) { // Reduced from 24 to compress vertical spacing
                        // Spacer for refresh animation
                        Color.clear
                            .frame(height: isRefreshing ? 140 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isRefreshing)
                        
                        // Header with Achievement Badge
                    VStack(spacing: 8) { // Reduced spacing to move content up // Reduced from 20 to compress spacing
                        // Welcome
                        HStack {
                            HStack(spacing: 10) {
                                LeafLogoView(size: 44)
                                
                                if isEditingName {
                                    // Inline text field
                                    HStack(spacing: 8) {
                                        Text("Welcome,")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        TextField("", text: $tempName)
                                            .placeholder(when: tempName.isEmpty) {
                                                Text("Your name")
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .focused($isNameFieldFocused)
                                            .onSubmit {
                                                if !tempName.isEmpty {
                                                    userName = tempName
                                                }
                                                isEditingName = false
                                            }
                                            .frame(width: 150)
                                    }
                                } else if userName.isEmpty {
                                    // No name set - show prompt
                                    Button(action: {
                                        tempName = ""
                                        isEditingName = true
                                        isNameFieldFocused = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Text("Welcome!")
                                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text("Tap to add name")
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.5))
                                                .underline()
                                        }
                                    }
                                } else {
                                    // Name exists - show it
                                    Button(action: {
                                        tempName = userName
                                        isEditingName = true
                                        isNameFieldFocused = true
                                    }) {
                                        HStack(spacing: 0) {
                                            Text("Welcome, \(userName)!")
                                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            Image(systemName: "pencil")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.3))
                                                .padding(.leading, 8)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            
                            // Streak flame
                            HStack(spacing: 4) {
                                FlameView()
                                Text("\(calculatedDaysClean)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Achievement System
                        AchievementCarousel(daysClean: calculatedDaysClean, showContent: showContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10) // Reduced from 50 to move content up
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    
                    // Daily Check-In Button - Between Achievement and Calendar
                    Button(action: { showingDailyCheckIn = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Daily Check-In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.7, blue: 0.4),
                                            Color(red: 0.15, green: 0.6, blue: 0.35)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(red: 0.2, green: 0.7, blue: 0.4).opacity(0.3), radius: 10, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 2) // Reduced from 4
                    .padding(.bottom, 4) // Reduced from 8
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                    
                    // Expandable Calendar Section
                    VStack(spacing: 0) {
                        if !calendarExpanded {
                            // Compact Week View
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("This week")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    // Hint to tap
                                    Text("Tap to view month")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                
                                HStack(spacing: 0) {
                                    ForEach(0..<7) { index in
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        checkedDays[index] ?
                                                        Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                        (index == todayIndex ?
                                                         Color(red: 0.15, green: 0.25, blue: 0.4) : // Blue for today pending
                                                         (index < todayIndex ? 
                                                          Color(red: 0.25, green: 0.08, blue: 0.08) : // Red for missed
                                                          Color(red: 0.1, green: 0.1, blue: 0.1))) // Dark for future
                                                    )
                                                    .frame(width: 32, height: 32)
                                                
                                                // Today indicator
                                                if index == todayIndex {
                                                    Circle()
                                                        .stroke(
                                                            checkedDays[index] ?
                                                            Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                            Color(red: 0.3, green: 0.5, blue: 0.8), // Blue for pending
                                                            lineWidth: 2
                                                        )
                                                        .frame(width: 36, height: 36)
                                                }
                                                
                                                if checkedDays[index] {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                } else if index == todayIndex {
                                                    // Today but not checked in yet - show question mark
                                                    Image(systemName: "questionmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.8))
                                                } else if index < todayIndex {
                                                    // Past days without check-in - show X
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                                }
                                            }
                                            
                                            Text(weekDays[index].prefix(1))
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(
                                                    checkedDays[index] ? 
                                                    .white.opacity(0.7) : 
                                                    (index == todayIndex ?
                                                     Color(red: 0.3, green: 0.5, blue: 0.8).opacity(0.8) : // Blue for today
                                                     (index < todayIndex ? 
                                                      Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.6) : // Red for missed
                                                      .gray.opacity(0.5))) // Gray for future
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                        .opacity(index > todayIndex ? 0.5 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Update cache before expanding
                                updateCalendarCache()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    calendarExpanded = true
                                }
                            }
                        } else {
                            // Expanded Month View
                            VStack(spacing: 16) {
                                // Month navigation header
                                HStack {
                                    Button(action: {
                                        if canNavigateToPreviousMonth {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                                updateCalendarCache()
                                            }
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(canNavigateToPreviousMonth ? .white.opacity(0.7) : .white.opacity(0.2))
                                            .scaleEffect(canNavigateToPreviousMonth ? 1.0 : 0.9)
                                    }
                                    .disabled(!canNavigateToPreviousMonth)
                                    
                                    Spacer()
                                    
                                    Text(monthYearString)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if canNavigateToNextMonth {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                                updateCalendarCache()
                                            }
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(canNavigateToNextMonth ? .white.opacity(0.7) : .white.opacity(0.2))
                                            .scaleEffect(canNavigateToNextMonth ? 1.0 : 0.9)
                                    }
                                    .disabled(!canNavigateToNextMonth)
                                }
                                
                                // Week day headers
                                HStack(spacing: 0) {
                                    ForEach(weekDays, id: \.self) { day in
                                        Text(day.prefix(3))
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                // Month grid with optimized rendering
                                if isLoadingCalendar {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(height: 200)
                                } else {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
                                        ForEach(0..<42, id: \.self) { index in
                                            let date = cachedMonthDates.indices.contains(index) ? cachedMonthDates[index] : nil
                                            
                                            ZStack {
                                                if let date = date {
                                                    Circle()
                                                        .fill(
                                                            isDateCheckedCached(at: index) ?
                                                            Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                            (isToday(date) ?
                                                             Color(red: 0.15, green: 0.25, blue: 0.4) : // Blue for today pending
                                                             (isPastDate(date) ?
                                                              Color(red: 0.25, green: 0.08, blue: 0.08) : // Red for missed
                                                              Color(red: 0.1, green: 0.1, blue: 0.1))) // Dark for future
                                                        )
                                                        .frame(width: 36, height: 36)
                                                
                                                    // Today indicator - optimized animation
                                                    if isToday(date) {
                                                        Circle()
                                                            .stroke(
                                                                isDateCheckedCached(at: index) ?
                                                                Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                                Color(red: 0.3, green: 0.5, blue: 0.8), // Blue for pending
                                                                lineWidth: 2
                                                            )
                                                            .frame(width: 40, height: 40)
                                                    }
                                                    
                                                    if isDateCheckedCached(at: index) {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(.white)
                                                    } else if isToday(date) {
                                                        // Today but not checked in yet - show question mark
                                                        Image(systemName: "questionmark")
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.8))
                                                    } else if isPastDate(date) {
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                                    } else {
                                                        Text("\(Self.sharedCalendar.component(.day, from: date))")
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(
                                                                isFutureDate(date) ? .gray.opacity(0.3) : .white.opacity(0.7)
                                                            )
                                                    }
                                                } else {
                                                    Color.clear
                                                        .frame(width: 36, height: 36)
                                                }
                                            }
                                            .opacity(isFutureDate(date) ? 0.5 : 1.0)
                                            .accessibilityLabel(getAccessibilityLabel(for: date, at: index))
                                            .accessibilityAddTraits(isToday(date) ? .isSelected : [])
                                        }
                                    }
                                }
                                
                                // Collapse hint
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.compact.up")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.4))
                                    Text("Swipe up to collapse")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.4))
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                            .padding(16)
                            .gesture(
                                DragGesture()
                                    .onEnded { value in
                                        if value.translation.height < Self.swipeThreshold {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                calendarExpanded = false
                                            }
                                        }
                                    }
                            )
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.06, green: 0.08, blue: 0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                    
                    // Days Counter Card
                    VStack(spacing: 8) { // Reduced spacing to move content up
                        Text("\(countedDays)")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: countedDays)
                        
                        Text("Days Sober")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20) // Reduced from 32 to move content up
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                    
                    // Milestones with progress bar
                    VStack(spacing: 8) { // Reduced spacing to move content up
                        HStack {
                            Text("Milestones")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(min(100, Int((Double(calculatedDaysClean) / 30.0) * 100)))% to month")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.7, blue: 0.3),
                                                Color(red: 0.3, green: 0.7, blue: 0.4)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * min(Double(calculatedDaysClean) / 30.0, 1.0), height: 4)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: calculatedDaysClean)
                            }
                        }
                        .frame(height: 4)
                        
                        HStack(spacing: 0) {
                            MilestoneBadge(days: 7, isUnlocked: calculatedDaysClean >= 7, title: "Week")
                            MilestoneBadge(days: 14, isUnlocked: calculatedDaysClean >= 14, title: "2 Weeks")
                            MilestoneBadge(days: 30, isUnlocked: calculatedDaysClean >= 30, title: "Month")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.06, green: 0.08, blue: 0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    
                    // Stats Cards with Clear Labels  
                    VStack(spacing: 8) { // Reduced spacing to move content up
                        // Time Reclaimed Card
                        InteractiveStatCard(
                            icon: "clock.fill",
                            iconColor: Color(red: 0.4, green: 0.7, blue: 1),
                            title: "Time Reclaimed",
                            value: calculatedTimeSaved.fullDisplay,
                            subtitle: calculatedTimeSaved.metaphor,
                            explanation: "Hours you would have spent high, obtaining cannabis, or recovering from use"
                        )
                        
                        // Money Saved Card
                        InteractiveStatCard(
                            icon: "dollarsign.circle.fill",
                            iconColor: Color(red: 0.4, green: 0.8, blue: 0.4),
                            title: "Money Saved",
                            value: calculatedMoneySaved.amount,
                            subtitle: calculatedMoneySaved.metaphor,
                            explanation: "Money you would have spent on cannabis products"
                        )
                        
                        // Cannabis Avoided Card
                        InteractiveStatCard(
                            icon: "leaf",
                            iconColor: Color(red: 0.9, green: 0.4, blue: 0.4),
                            title: "Not Consumed",
                            value: calculatedJointsAvoided.fullDisplay,
                            subtitle: calculatedJointsAvoided.metaphor,
                            explanation: "Amount of cannabis you haven't consumed since quitting"
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    
                    // Quick Actions - Part of Content
                    HStack(spacing: 8) {
                        QuickActionPill(icon: "wind", text: "Breathe", action: { showingBreathe = true })
                        QuickActionPill(icon: "book.fill", text: "Journal", action: { showingJournal = true })
                        QuickActionPill(icon: "phone.fill", text: "Call", action: { showingContacts = true })
                        QuickActionPill(icon: "lightbulb.fill", text: "Tips", action: { showingTips = true })
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                    
                    // Extra padding to account for floating emergency button and tab bar
                    // Emergency button: 56 height + 20 padding + 12 spacing = 88
                    // Tab bar: 65 height + 20 bottom padding = 85  
                    // Total needed: ~173, adding extra for safe scrolling
                    Spacer(minLength: 180)
                }
            }
            .refreshable {
                await performRefresh()
            }
            
            } // Close the ZStack(alignment: .top)
        } // Close the main ZStack
        .ignoresSafeArea(.container, edges: .bottom)
        .fullScreenCover(isPresented: $showingDailyCheckIn) {
            DailyCheckInView()
        }
        .fullScreenCover(isPresented: $showingBreathe) {
            BreatheView()
        }
        .fullScreenCover(isPresented: $showingPanicButton) {
            PanicButtonView()
        }
        .fullScreenCover(isPresented: $showingJournal) {
            JournalFeatureView()
        }
        .fullScreenCover(isPresented: $showingContacts) {
            EmergencyContactsView()
        }
        .fullScreenCover(isPresented: $showingTips) {
            TipsView()
        }
        .onTapGesture {
            // Dismiss keyboard and save when tapping outside
            if isEditingName {
                if !tempName.isEmpty {
                    userName = tempName
                }
                isEditingName = false
                isNameFieldFocused = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenDailyCheckIn"))) { _ in
            showingDailyCheckIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CelebrateMilestone"))) { notification in
            if let milestone = notification.userInfo?["milestone"] as? Int {
                // Could show a special celebration view here
                print("Celebrating \(milestone) day milestone!")
            }
        }
        .onAppear {
            // Initialize quit date if not set
            if quitDateString.isEmpty {
                quitDateString = ISO8601DateFormatter().string(from: Date())
            } else {
                // Validate quit date is not in future
                if let quitDate = ISO8601DateFormatter().date(from: quitDateString) {
                    let calendar = Calendar.current
                    if calendar.startOfDay(for: quitDate) > calendar.startOfDay(for: Date()) {
                        // Reset future quit date to today
                        quitDateString = ISO8601DateFormatter().string(from: Date())
                    }
                }
            }

            reconcileStreakIfNeeded()
            
            withAnimation(.easeOut(duration: 0.5)) {
                animateGradient = true
                showContent = true
            }
            
            // Force update the displayed days to match current streak
            // This ensures the counter always shows the correct value
            let currentDaysSober = calculatedDaysClean
            if countedDays != currentDaysSober {
                // If there's a mismatch, update immediately without animation
                countedDays = currentDaysSober
            }
            
            // Then animate if needed for visual effect
            animateDaysClean(to: currentDaysSober)
            
            // Initialize calendar cache
            updateCalendarCache()
        }
        .onChange(of: calculatedDaysClean) { oldValue, newValue in
            animateDaysClean(to: newValue)
        }
        .onChange(of: checkInDatesString) { _, _ in
            // Always update cache when check-in dates change
            updateCalendarCache()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Update when app becomes active to ensure display is always current
            let currentDaysSober = calculatedDaysClean
            if countedDays != currentDaysSober {
                countedDays = currentDaysSober
            }
        }
        .onDisappear {
            daysCountTask?.cancel()
            daysCountTask = nil
            midnightTimer?.invalidate()
            midnightTimer = nil
        }
        .task {
            setupMidnightTimer()
        }
    }
    private func performRefresh() async {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Mark as refreshing with smooth animation
        await MainActor.run {
            print("DEBUG: Setting isRefreshing to true")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isRefreshing = true
            }
        }
        
        // Refresh data
        streakManager.validateStreak()
        reconcileStreakIfNeeded()
        
        // Update displayed days
        let currentDaysSober = calculatedDaysClean
        if countedDays != currentDaysSober {
            await MainActor.run {
                animateDaysClean(to: currentDaysSober)
            }
        }
        
        // Update calendar cache if expanded
        if calendarExpanded {
            updateCalendarCache()
        }
        
        // Simulate minimum refresh time for UX - increased to 3 seconds
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Complete refresh with smooth spring animation
        await MainActor.run {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isRefreshing = false
            }
        }
    }
    
    private func animateDaysClean(to target: Int) {
        let clampedTarget = max(target, 0)
        if countedDays == clampedTarget { return }

        daysCountTask?.cancel()

        let start = countedDays
        let delta = clampedTarget - start
        let steps = min(max(1, abs(delta)), 60)
        let increment = Double(delta) / Double(steps)
        let frameDelay: UInt64 = 20_000_000 // 20ms

        daysCountTask = Task {
            var currentValue = Double(start)
            for _ in 0..<steps {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: frameDelay)
                currentValue += increment
                await MainActor.run {
                    countedDays = Int(round(currentValue))
                }
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                countedDays = clampedTarget
            }
        }
    }

    private func reconcileStreakIfNeeded() {
        // Reset streak if no check-in date exists
        guard !lastCheckInDateString.isEmpty else {
            streakManager.validateStreak()
            return
        }

        let formatter = ISO8601DateFormatter()
        // Validate date format
        guard let lastDate = formatter.date(from: lastCheckInDateString) else {
            // Invalid date format - reset streak for safety
            streakManager.validateStreak()
            return
        }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastDate)
        let today = calendar.startOfDay(for: Date())
        let delta = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        // Streak grace period: Allow 1 missed day (48 hours) before breaking streak
        // This is more forgiving for users who might miss a single day
        let gracePeriodDays = 2 // User has up to 2 days to check in
        
        if delta > gracePeriodDays {
            // Streak breaks after missing more than 1 day
            streakManager.validateStreak()
        }
    }
    
    private func setupMidnightTimer() {
        // Cancel any existing timer
        midnightTimer?.invalidate()
        
        // Calculate seconds until midnight
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
        let midnight = calendar.startOfDay(for: tomorrow)
        
        let secondsUntilMidnight = midnight.timeIntervalSince(now)
        
        // Set timer to fire at midnight
        midnightTimer = Timer.scheduledTimer(withTimeInterval: secondsUntilMidnight, repeats: false) { _ in
            // Update current date to trigger view refresh
            withAnimation {
                currentDate = Date()
            }
            
            // Check and update streak status
            streakManager.validateStreak()
            
            // Update the displayed counter to match days sober
            let currentDaysSober = calculatedDaysClean
            animateDaysClean(to: currentDaysSober)
            
            // Setup timer for next midnight
            setupMidnightTimer()
        }
    }
}

// New supporting views
struct QuickActionPill: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(text)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }
}

// Removed StatPill as stats are now full cards with labels

struct MilestoneBadge: View {
    let days: Int
    let isUnlocked: Bool
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? [
                                Color(red: 0.9, green: 0.7, blue: 0.3),
                                Color(red: 0.8, green: 0.6, blue: 0.2)
                            ] : [
                                Color(red: 0.08, green: 0.08, blue: 0.08),
                                Color(red: 0.08, green: 0.08, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                isUnlocked ?
                                Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.3) :
                                Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
                
                if isUnlocked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(days)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isUnlocked ? .white.opacity(0.9) : .white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

// Achievement System Components
struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let daysRequired: Int
    let color1: Color
    let color2: Color
    let description: String
}

// Preference key for tracking ScrollView offset
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Preference key for tracking scroll position in achievement carousel
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct AchievementCarousel: View {
    let daysClean: Int
    let showContent: Bool
    @State private var selectedIndex = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var lastUpdateTime = Date()
    
    let achievements = [
        Achievement(name: "Seedling", icon: "🌱", daysRequired: 1,
                   color1: Color(red: 0.4, green: 0.8, blue: 0.4),
                   color2: Color(red: 0.3, green: 0.7, blue: 0.3),
                   description: "Your journey begins"),
        Achievement(name: "Sprout", icon: "🌿", daysRequired: 3,
                   color1: Color(red: 0.3, green: 0.8, blue: 0.6),
                   color2: Color(red: 0.2, green: 0.7, blue: 0.5),
                   description: "Growing stronger"),
        Achievement(name: "Sapling", icon: "🌳", daysRequired: 7,
                   color1: Color(red: 0.3, green: 0.7, blue: 0.8),
                   color2: Color(red: 0.2, green: 0.6, blue: 0.7),
                   description: "One week strong"),
        Achievement(name: "Tree", icon: "🌲", daysRequired: 14,
                   color1: Color(red: 0.4, green: 0.6, blue: 0.8),
                   color2: Color(red: 0.3, green: 0.5, blue: 0.7),
                   description: "Two weeks rooted"),
        Achievement(name: "Warrior", icon: "⚔️", daysRequired: 30,
                   color1: Color(red: 0.9, green: 0.6, blue: 0.2),
                   color2: Color(red: 0.8, green: 0.5, blue: 0.1),
                   description: "Battle tested"),
        Achievement(name: "Ascendant", icon: "✨", daysRequired: 45,
                   color1: Color(red: 0.9, green: 0.7, blue: 0.3),
                   color2: Color(red: 0.8, green: 0.6, blue: 0.2),
                   description: "Rising above"),
        Achievement(name: "Champion", icon: "🏆", daysRequired: 60,
                   color1: Color(red: 0.9, green: 0.4, blue: 0.4),
                   color2: Color(red: 0.8, green: 0.3, blue: 0.3),
                   description: "Proven champion"),
        Achievement(name: "Enlightenment", icon: "🧘", daysRequired: 90,
                   color1: Color(red: 0.6, green: 0.4, blue: 0.8),
                   color2: Color(red: 0.5, green: 0.3, blue: 0.7),
                   description: "Inner peace achieved"),
        Achievement(name: "Legend", icon: "⭐", daysRequired: 180,
                   color1: Color(red: 0.9, green: 0.7, blue: 0.2),
                   color2: Color(red: 0.8, green: 0.5, blue: 0.1),
                   description: "Legendary status"),
        Achievement(name: "Sage", icon: "👑", daysRequired: 365,
                   color1: Color(red: 0.9, green: 0.9, blue: 0.9),
                   color2: Color(red: 0.7, green: 0.7, blue: 0.7),
                   description: "Ultimate wisdom")
    ]
    
    var currentAchievementIndex: Int {
        // Find the highest achievement unlocked
        for (index, achievement) in achievements.enumerated().reversed() {
            if daysClean >= achievement.daysRequired {
                return index
            }
        }
        return 0
    }
    
    var currentAchievement: Achievement {
        achievements[currentAchievementIndex]
    }
    
    var nextAchievement: Achievement? {
        guard currentAchievementIndex < achievements.count - 1 else { return nil }
        return achievements[currentAchievementIndex + 1]
    }
    
    var progressToNext: Double {
        guard let next = nextAchievement else { return 1.0 }
        let current = currentAchievement
        let progress = Double(daysClean - current.daysRequired) / Double(next.daysRequired - current.daysRequired)
        return min(max(progress, 0), 1)
    }
    
    @ViewBuilder
    var achievementScrollView: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(achievements.indices, id: \.self) { index in
                            achievementBadgeView(for: index, scrollProxy: scrollProxy)
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - 140) / 2)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    if !value.isEmpty && !isDragging {
                        let currentTime = Date()
                        guard currentTime.timeIntervalSince(lastUpdateTime) > 0.1 else { return }
                        lastUpdateTime = currentTime
                        
                        let centerX = geometry.size.width / 2
                        var minDistance: CGFloat = .infinity
                        var closestIndex = 0
                        
                        for (index, offset) in value {
                            let distance = abs(offset - centerX)
                            if distance < minDistance {
                                minDistance = distance
                                closestIndex = index
                            }
                        }
                        
                        if closestIndex != selectedIndex && minDistance < 50 {
                            selectedIndex = closestIndex
                        }
                    }
                }
                .onAppear {
                    selectedIndex = currentAchievementIndex
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollProxy.scrollTo(currentAchievementIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(height: 180)
    }
    
    @ViewBuilder
    func achievementBadgeView(for index: Int, scrollProxy: ScrollViewProxy) -> some View {
        AchievementBadge(
            achievement: achievements[index],
            isUnlocked: daysClean >= achievements[index].daysRequired,
            isCurrent: index == currentAchievementIndex,
            isSelected: index == selectedIndex,
            progress: index == currentAchievementIndex ? progressToNext : (index < currentAchievementIndex ? 1.0 : 0.0),
            showContent: showContent,
            index: index
        )
        .frame(width: 140, height: 180)
        .id(index)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedIndex = index
                scrollProxy.scrollTo(index, anchor: .center)
            }
        }
        .background(
            GeometryReader { itemGeo in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self,
                              value: [index: itemGeo.frame(in: .named("scroll")).midX])
            }
        )
    }
    
    @ViewBuilder
    var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(achievements.indices, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? 
                          Color.white : 
                          Color.white.opacity(0.3))
                    .frame(width: index == selectedIndex ? 8 : 6, 
                           height: index == selectedIndex ? 8 : 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
            }
        }
    }
    
    @ViewBuilder
    var achievementInfoView: some View {
        VStack(spacing: 12) {
            Text(achievements[selectedIndex].name.uppercased())
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 8)
            
            if selectedIndex == currentAchievementIndex {
                Text("Day \(daysClean) of \(nextAchievement?.daysRequired ?? achievements[selectedIndex].daysRequired)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                if let next = nextAchievement {
                    Text("\(next.daysRequired - daysClean) days to \(next.name)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else if selectedIndex < currentAchievementIndex {
                Text("Achieved! • Day \(achievements[selectedIndex].daysRequired)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
            } else {
                Text("Locked • \(achievements[selectedIndex].daysRequired) days required")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Text(achievements[selectedIndex].description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            achievementScrollView
            pageIndicators
                .padding(.top, -8)
            achievementInfoView
                .padding(.top, 8)
        }
        .frame(height: 360)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial.opacity(0.3))
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let isCurrent: Bool
    let isSelected: Bool
    let progress: Double
    let showContent: Bool
    let index: Int
    
    @State private var animateGlow = false
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var particleAnimation = false
    @State private var breathingScale: CGFloat = 1.0
    @State private var iconBounce = false
    @State private var particleOffsets: [CGFloat] = []
    @State private var bounceTimer: Timer?
    @State private var pulseOpacity: Double = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Floating particles for current achievement
                if isCurrent && !particleOffsets.isEmpty {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(achievement.color1.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .offset(y: particleAnimation ? -80 : 0)
                            .opacity(particleAnimation ? 0 : 0.8)
                            .animation(
                                Animation.easeOut(duration: 3)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.5),
                                value: particleAnimation
                            )
                            .offset(x: particleOffsets[i])
                    }
                }
                
                // Ambient glow layer
                if isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    achievement.color1.opacity(0.3),
                                    achievement.color1.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 70
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .opacity(isSelected ? 1.0 : 0.3)
                        .scaleEffect(animateGlow ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGlow)
                }
                
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? [achievement.color1, achievement.color2] : [Color.gray.opacity(0.25), Color.gray.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .overlay(
                        // Subtle pulse effect for unlocked achievements
                        isUnlocked && !isCurrent ?
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [achievement.color1.opacity(pulseOpacity), achievement.color2.opacity(pulseOpacity)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .scaleEffect(1.0 + pulseOpacity * 0.1)
                        : nil
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: isUnlocked ?
                                    [achievement.color1.opacity(0.8), achievement.color2.opacity(0.8)] :
                                    [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 3 : 2
                            )
                    )
                    .scaleEffect(breathingScale)
                    .animation(
                        isCurrent ?
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true) : nil,
                        value: breathingScale
                    )
                
                // Progress ring for current achievement
                if isCurrent && progress < 1 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.white.opacity(0.5), radius: 4)
                        .animation(.spring(response: 1, dampingFraction: 0.8), value: progress)
                }
                
                // Icon - always show but grayed when locked
                Text(achievement.icon)
                    .font(.system(size: 48))
                    .saturation(isUnlocked ? 1.0 : 0)
                    .opacity(isUnlocked ? 1.0 : 0.4)
                    .scaleEffect(iconBounce ? 1.2 : 1.0)
                    .offset(y: floatOffset)
                    .rotationEffect(.degrees(rotationAngle))
                
                // Lock overlay for locked achievements
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                        .offset(x: 35, y: -35)
                }
            }
            .frame(width: 110, height: 110)
            
            Text(achievement.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))
                .lineLimit(1)
        }
        .offset(y: floatOffset * 0.5)
        .scaleEffect(showContent ? (isSelected ? 1.1 : 0.9) : 0.8)
        .opacity(showContent ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05 + 0.2), value: showContent)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .onAppear {
            // Initialize particle offsets
            if particleOffsets.isEmpty {
                particleOffsets = (0..<6).map { _ in CGFloat.random(in: -30...30) }
            }
            
            // Start all animations with delays to prevent all starting at once
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                animateGlow = true
                particleAnimation = true
                
                // Pulse animation for unlocked achievements
                if isUnlocked && !isCurrent {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(Double(index) * 0.3)) {
                        pulseOpacity = 0.5
                    }
                }
                
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatOffset = -5
                }
                
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    rotationAngle = -3
                }
                
                if isCurrent {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        breathingScale = 1.05
                    }
                }
            }
            
            // Icon bounce for unlocked achievements
            if isUnlocked && !isCurrent {
                let interval = Double.random(in: 5...8)
                bounceTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak bounceTimer] _ in
                    guard bounceTimer != nil else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        iconBounce = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        iconBounce = false
                    }
                }
            }
        }
        .onDisappear {
            // Clean up timer
            bounceTimer?.invalidate()
            bounceTimer = nil
        }
    }
}

// Clickable Stat Card Component
struct InteractiveStatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    let explanation: String
    
    @State private var showExplanation = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showExplanation.toggle()
            }
        }) {
            VStack(spacing: 0) {
                // Main content
                VStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(iconColor)
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Image(systemName: showExplanation ? "info.circle.fill" : "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(showExplanation ? 0.6 : 0.3))
                            .rotationEffect(.degrees(showExplanation ? 180 : 0))
                    }
                    
                    VStack(spacing: 6) {
                        Text(value)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // Explanation (shown when tapped)
                if showExplanation {
                    VStack {
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Text(explanation)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(showExplanation ? 0.08 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        iconColor.opacity(showExplanation ? 0.3 : 0),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

// Emergency Help Button Component
struct EmergencyHelpButton: View {
    @State private var isPressed = false
    @State private var pulseAnimation = false
    @State private var heartBeat = false
    @State private var showingPanicButton = false
    
    var body: some View {
        Button(action: {
            showingPanicButton = true
        }) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.8, green: 0.14, blue: 0.21),  // Deep red
                                Color(red: 1.0, green: 0.23, blue: 0.28)   // Bright red
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.ultraThinMaterial.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -5)
                
                HStack(spacing: 12) {
                    // Pulsing heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(heartBeat ? 1.2 : 1.0)
                    
                    Text("I Need Help")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // SOS Badge
                    Text("SOS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 56)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .fullScreenCover(isPresented: $showingPanicButton) {
            PanicButtonView()
        }
        .onAppear {
            // Start breathing animation for gradient
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            
            // Start heartbeat animation
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                heartBeat = true
            }
        }
    }
}

// Beautiful plant rebirth animation for counter reset
struct ResetAnimationView: View {
    @Binding var isShowing: Bool
    @State private var currentMessage = 0
    @State private var messageOpacity = 0.0
    @State private var seedScale = 0.0
    @State private var seedRotation = 0.0
    @State private var plantGrowth = 0.0
    @State private var leafParticles: [LeafParticle] = []
    @State private var glowOpacity = 0.0
    @State private var screenSize = CGSize.zero
    
    let messages = [
        "It's okay to start over",
        "Every journey has restarts",
        "Planting new seeds..."
    ]
    
    struct LeafParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with gradient
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.95)
            
            // Falling leaves effect
            ForEach(leafParticles) { leaf in
                Text("🍃")
                    .font(.system(size: 30))
                    .rotationEffect(.degrees(leaf.rotation))
                    .scaleEffect(leaf.scale)
                    .opacity(leaf.opacity)
                    .position(x: leaf.x, y: leaf.y)
            }
            
            VStack(spacing: 60) {
                // Animated seed/plant
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.6),
                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .opacity(glowOpacity)
                        .scaleEffect(plantGrowth > 0 ? 1.5 : 1.0)
                    
                    // Seed transforming to seedling
                    Group {
                        if plantGrowth == 0 {
                            // Seed
                            Text("🌰")
                                .font(.system(size: 60))
                                .scaleEffect(seedScale)
                                .rotationEffect(.degrees(seedRotation))
                        } else {
                            // Growing seedling
                            Text("🌱")
                                .font(.system(size: 80))
                                .scaleEffect(plantGrowth)
                                .rotationEffect(.degrees(plantGrowth > 0 ? -5 : 0))
                        }
                    }
                }
                
                // Messages
                VStack(spacing: 20) {
                    if currentMessage < messages.count {
                        Text(messages[currentMessage])
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(messageOpacity)
                            .animation(.easeInOut(duration: 0.6), value: messageOpacity)
                    }
                    
                    // Day 0 indicator
                    if currentMessage == messages.count - 1 {
                        VStack(spacing: 8) {
                            Text("Day 0")
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                .opacity(plantGrowth)
                            
                            Text("Your new beginning")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .opacity(plantGrowth)
                        }
                    }
                }
            }
            }
            .onAppear {
                screenSize = geometry.size
                startAnimation()
            }
        }
    }
    
    func startAnimation() {
        // Create falling leaves
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                let leaf = LeafParticle(
                    x: CGFloat.random(in: 50...max(screenSize.width - 50, 100)),
                    y: -50,
                    rotation: Double.random(in: 0...360),
                    scale: CGFloat.random(in: 0.6...1.2),
                    opacity: Double.random(in: 0.6...1.0)
                )
                leafParticles.append(leaf)
                
                // Animate leaf falling
                withAnimation(.easeIn(duration: 2.5)) {
                    if let index = leafParticles.firstIndex(where: { $0.id == leaf.id }) {
                        leafParticles[index].y = screenSize.height + 100
                        leafParticles[index].rotation += Double.random(in: 180...540)
                        leafParticles[index].opacity = 0
                    }
                }
            }
        }
        
        // Message sequence
        showMessage(0)
    }
    
    func showMessage(_ index: Int) {
        guard index < messages.count else {
            // Plant the seed and grow
            plantSeedAndGrow()
            return
        }
        
        currentMessage = index
        
        withAnimation(.easeIn(duration: 0.5)) {
            messageOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                messageOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showMessage(index + 1)
            }
        }
    }
    
    func plantSeedAndGrow() {
        // Show final message
        currentMessage = messages.count - 1
        withAnimation(.easeIn(duration: 0.5)) {
            messageOpacity = 1.0
        }
        
        // Show and plant seed
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            seedScale = 1.0
        }
        
        // Rotate seed (planting animation)
        withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
            seedRotation = 360
        }
        
        // Transform to seedling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                plantGrowth = 1.0
                glowOpacity = 1.0
            }
            
            // Dismiss after showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowing = false
                }
                
                // Clear the flag
                UserDefaults.standard.set(false, forKey: "justResetCounter")
            }
        }
    }
}

// Animated flame component
struct FlameView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var glow: Double = 0.5
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Text("🔥")
            .font(.system(size: 20))
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(y: yOffset)
            .shadow(color: Color.orange.opacity(glow), radius: 10)
            .shadow(color: Color.red.opacity(glow * 0.7), radius: 15)
            .shadow(color: Color.yellow.opacity(glow * 0.3), radius: 5)
            .onAppear {
                // Start all animations
                startAnimations()
            }
    }
    
    private func startAnimations() {
        // Flickering scale animation
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
        
        // Subtle rotation animation  
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            rotation = 8
        }
        
        // Glowing animation
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            glow = 1.0
        }
        
        // Gentle floating animation
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            yOffset = -2
        }
    }
}

// Pull to Refresh Plant View - Shows animated plant based on pull distance
struct PullToRefreshPlantView: View {
    let offset: CGFloat
    let isRefreshing: Bool
    let isDragging: Bool
    
    @State private var plantRotation: Double = 0
    @State private var leafFloat: CGFloat = 0
    
    private var pullProgress: CGFloat {
        min(offset / 100, 1.0)
    }
    
    private var plantScale: CGFloat {
        0.5 + pullProgress * 0.5
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Plant that grows as you pull
            ZStack {
                // Glow effect when almost ready
                if pullProgress > 0.7 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                        .scaleEffect(pullProgress)
                }
                
                // Plant emoji that changes based on progress
                Group {
                    if isRefreshing {
                        // Full plant when refreshing
                        Text("🌿")
                            .font(.system(size: 40))
                            .rotationEffect(.degrees(plantRotation))
                    } else if pullProgress < 0.3 {
                        // Seed
                        Text("🌰")
                            .font(.system(size: 30))
                            .opacity(1.0 - pullProgress * 2)
                    } else if pullProgress < 0.7 {
                        // Sprout
                        Text("🌱")
                            .font(.system(size: 35))
                            .scaleEffect(plantScale)
                            .rotationEffect(.degrees(pullProgress * 10))
                    } else {
                        // Almost there - bigger sprout
                        Text("🌿")
                            .font(.system(size: 38))
                            .scaleEffect(plantScale)
                            .rotationEffect(.degrees(Darwin.sin(pullProgress * .pi) * 5))
                            .offset(y: leafFloat)
                    }
                }
                .scaleEffect(isRefreshing ? 1.2 : 1.0)
            }
            
            // Status text
            if isRefreshing {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.7, blue: 0.4)))
                        .scaleEffect(0.7)
                    Text("Refreshing...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                }
            } else if pullProgress >= 1.0 {
                Text("Release to refresh")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                    .scaleEffect(1.1)
            } else if pullProgress > 0.5 {
                Text("Keep pulling...")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            } else if offset > 10 {
                Text("Pull to grow")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .opacity(offset > 5 ? 1.0 : offset / 5.0) // Fade in as pulling starts
        .onAppear {
            print("DEBUG: PullToRefreshPlantView appeared with offset: \(offset)")
            // Start animations
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                plantRotation = 10
                leafFloat = -3
            }
        }
        .onChange(of: offset) { _, newValue in
            print("DEBUG: Plant view offset changed to: \(newValue), progress: \(pullProgress)")
        }
    }
}

// Smooth Refresh Animation View
struct RefreshAnimationView: View {
    @State private var animationProgress: Double = 0
    @State private var currentStage = 0
    @State private var showCompletion = false
    
    let stages = [
        (emoji: "🌰", message: "Planting seeds..."),
        (emoji: "🌱", message: "Growing sprouts..."),
        (emoji: "🌿", message: "Refreshing garden..."),
        (emoji: "🌳", message: "Almost ready...")
    ]
    
    // Single source of truth for animation
    private var currentEmoji: String {
        if showCompletion { return "✓" }
        return stages[min(currentStage, stages.count - 1)].emoji
    }
    
    private var currentMessage: String {
        if showCompletion { return "Garden refreshed!" }
        return stages[min(currentStage, stages.count - 1)].message
    }
    
    // Smooth animation values derived from progress
    private var plantScale: CGFloat {
        1.0 + Darwin.sin(animationProgress * .pi * 2) * 0.1
    }
    
    private var plantRotation: Double {
        Darwin.sin(animationProgress * .pi * 4) * 8
    }
    
    private var glowIntensity: Double {
        0.3 + Darwin.sin(animationProgress * .pi * 2) * 0.2
    }
    
    var body: some View {
        VStack(spacing: 18) {
            // Plant display with subtle glow
            ZStack {
                // Simplified glow - no blur for performance
                Circle()
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                    .frame(width: 60, height: 60)
                    .opacity(glowIntensity)
                    .scaleEffect(1.2)
                
                // Single animated element
                Text(currentEmoji)
                    .font(.system(size: 42))
                    .scaleEffect(plantScale)
                    .rotationEffect(.degrees(plantRotation))
                    .foregroundColor(showCompletion ? Color(red: 0.3, green: 0.7, blue: 0.4) : .primary)
            }
            .frame(height: 80)
            
            // Message and progress indicator
            HStack(spacing: 10) {
                if !showCompletion {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.7, blue: 0.4)))
                        .scaleEffect(0.8)
                }
                
                Text(currentMessage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
            }
            .animation(.none, value: showCompletion) // Prevent text animation
            
            // Simple progress indicator
            ProgressBar(progress: Double(currentStage) / Double(stages.count - 1))
                .frame(height: 4)
                .frame(maxWidth: 150)
        }
        .onAppear {
            startSmoothAnimation()
        }
    }
    
    private func startSmoothAnimation() {
        // Single timeline animation
        withAnimation(.linear(duration: 2.8)) {
            animationProgress = 1.0
        }
        
        // Stage progression without Timer
        for i in 0..<stages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStage = i
                }
            }
        }
        
        // Show completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showCompletion = true
            }
        }
    }
}

// Simple progress bar component
struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                    .frame(width: geometry.size.width * progress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
    }
}

// Simple Refresh Indicator View
struct RefreshIndicatorView: View {
    let plantGrowth: CGFloat
    let showSeedling: Bool
    
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated plant
            Group {
                if showSeedling {
                    Text("🌿")
                        .font(.system(size: 28))
                        .scaleEffect(plantGrowth)
                        .rotationEffect(.degrees(rotation))
                } else {
                    Text("🌱")
                        .font(.system(size: 24))
                        .scaleEffect(0.8 + plantGrowth * 0.2)
                }
            }
            
            // Loading text
            Text("Refreshing your garden...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
            
            // Progress indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.7, blue: 0.4)))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                rotation = 10
            }
        }
    }
}

// Old Pull to Refresh View Component (keeping for reference but simplified)
struct PullToRefreshView: View {
    let pullOffset: CGFloat
    let isRefreshing: Bool
    let plantGrowth: CGFloat
    let leafRotation: Double
    let showSeedling: Bool
    
    @State private var leafParticles: [(id: Int, offset: CGSize, opacity: Double)] = []
    @State private var glowOpacity: Double = 0
    
    // Computed properties to break up complex expressions
    private var glowGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(glowOpacity),
                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(glowOpacity * 0.5),
                Color.clear
            ],
            center: .center,
            startRadius: 10,
            endRadius: 50
        )
    }
    
    private var glowEffect: some View {
        Circle()
            .fill(glowGradient)
            .frame(width: 100, height: 100)
            .blur(radius: 10)
            .scaleEffect(plantGrowth)
    }
    
    private var leafParticlesView: some View {
        ForEach(leafParticles, id: \.id) { particle in
            Text("🍃")
                .font(.system(size: 14))
                .offset(particle.offset)
                .opacity(particle.opacity)
                .rotationEffect(.degrees(Double(particle.id) * 60 + leafRotation * 2))
        }
    }
    
    private var seedView: some View {
        Text("🌰")
            .font(.system(size: 30))
            .scaleEffect(1.0 + plantGrowth * 0.3)
            .opacity(1.0 - plantGrowth)
    }
    
    private var seedlingView: some View {
        Text("🌱")
            .font(.system(size: 36))
            .scaleEffect(0.5 + plantGrowth * 0.8)
            .rotationEffect(.degrees(Darwin.sin(plantGrowth * .pi) * 5))
            .opacity(plantGrowth)
    }
    
    private var fullPlantView: some View {
        Text("🌿")
            .font(.system(size: 40))
            .scaleEffect(plantGrowth)
            .rotationEffect(.degrees(leafRotation))
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRefreshing)
    }
    
    private var statusTextView: some View {
        Group {
            if isRefreshing {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.7, blue: 0.4)))
                        .scaleEffect(0.8)
                    Text("Refreshing...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                }
            } else if pullOffset > 100 {
                Text("Release to refresh")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                    .scaleEffect(1.1)
            } else if pullOffset > 50 {
                Text("Keep pulling...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            } else if pullOffset > 20 {
                Text("Pull to grow")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow effect when growing
                if plantGrowth > 0.3 {
                    glowEffect
                }
                
                // Floating leaf particles
                leafParticlesView
                
                // Main plant animation
                ZStack {
                    if !showSeedling {
                        seedView
                    }
                    
                    if showSeedling && !isRefreshing {
                        seedlingView
                    }
                    
                    if isRefreshing {
                        fullPlantView
                    }
                }
                .offset(y: pullOffset * 0.3) // Elastic stretch effect
            }
            
            // Status text
            statusTextView
                .animation(.easeOut(duration: 0.2), value: pullOffset)
        }
        .padding(.top, max(20, pullOffset * 0.5)) // Dynamic padding based on pull
        .onAppear {
            generateLeafParticles()
        }
        .onChange(of: plantGrowth) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                glowOpacity = newValue * 0.6
            }
            
            // Update leaf particles
            if newValue > 0.5 && leafParticles.isEmpty {
                generateLeafParticles()
            }
        }
        .onChange(of: isRefreshing) { _, newValue in
            if newValue {
                animateLeafParticles()
            }
        }
    }
    
    private func generateLeafParticles() {
        leafParticles = (0..<6).map { i in
            (
                id: i,
                offset: CGSize.zero,
                opacity: 0.0
            )
        }
    }
    
    private func animateLeafParticles() {
        for i in 0..<leafParticles.count {
            withAnimation(.easeOut(duration: 2.0).delay(Double(i) * 0.1)) {
                let angle = Double(i) * 60.0 * .pi / 180.0
                let radius = 30.0 + Double(i) * 5
                leafParticles[i].offset = CGSize(
                    width: cos(angle) * radius,
                    height: sin(angle) * radius
                )
                leafParticles[i].opacity = 0.6
            }
            
            // Fade out after animation
            withAnimation(.easeOut(duration: 0.5).delay(2.0 + Double(i) * 0.1)) {
                leafParticles[i].opacity = 0
            }
        }
    }
}

// Tab Content View - Simple fade without white flash
struct TabContentView<Content: View>: View {
    let selectedTab: Int
    let content: () -> Content
    
    var body: some View {
        ZStack {
            // Black background to prevent white flash
            Color.black
                .ignoresSafeArea()
            
            content()
                .id(selectedTab) // Force view recreation
                .transition(.asymmetric(
                    insertion: .opacity.animation(.easeIn(duration: 0.2)),
                    removal: .opacity.animation(.easeOut(duration: 0.1))
                ))
        }
        .background(Color.black) // Ensure black background
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
