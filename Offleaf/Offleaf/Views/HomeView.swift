//
//  HomeView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @State private var selectedTab = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("weeklySpending") private var weeklySpending: Double = 0
    @AppStorage("smokeFrequency") private var smokeFrequencyRaw = CannabisUseFrequency.unknown.rawValue
    @AppStorage("quitDate") private var quitDateString = ""
    @AppStorage("justResetCounter") private var justResetCounter = false
    @AppStorage("checkInStreak") private var checkInStreak = 0
    @AppStorage("checkInDates") private var checkInDatesString = ""
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    @State private var isEditingName = false
    @State private var tempName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var daysClean = 0
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
    @State private var floatingAnimation = false
    @State private var showResetAnimation = false
    @State private var daysCountTask: Task<Void, Never>? = nil
    
    // Calendar data
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
        let today = calendar.startOfDay(for: Date())
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
        max(checkInStreak, 0)
    }
    
    // Calculate money saved
    var calculatedMoneySaved: (amount: String, context: String, metaphor: String) {
        // Use baseline of $15/day if no spending data provided
        let baselineWeeklySpending = 105.0 // $15 per day * 7 days
        let effectiveSpending = weeklySpending > 0 ? weeklySpending : baselineWeeklySpending
        
        let dailySpending = effectiveSpending / 7.0
        let totalSaved = dailySpending * Double(calculatedDaysClean)
        
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
        let totalHours = frequency.estimatedHoursPerDay * Double(calculatedDaysClean)
        
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
        let totalJoints = Int(jointsPerDay * Double(calculatedDaysClean))
        let totalGrams = gramsPerDay * Double(calculatedDaysClean)
        
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
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    homeContent
                case 1:
                    LearnView()
                case 2:
                    ProgressTabView()
                case 3:
                    ProfileView()
                default:
                    homeContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom stack with emergency button and tab bar
            VStack(spacing: 16) {
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
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CounterReset"))) { _ in
            // Delay to ensure view has settled after dismissal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Reset to day 0
                daysClean = 0
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
            // Pure black background
            Color.black
                .ignoresSafeArea()
            
            // Huge vibrant orb like Quittr
            HeroOrbView(animating: $floatingAnimation)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with Achievement Badge
                    VStack(spacing: 20) {
                        // Welcome
                        HStack {
                            HStack(spacing: 10) {
                                LeafLogoView(size: 32)
                                
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
                                Text("🔥")
                                    .font(.system(size: 20))
                                Text("\(max(checkInStreak, 0))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Achievement System
                        AchievementCarousel(daysClean: calculatedDaysClean, showContent: showContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    
                    // Compact Streak Calendar
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This week")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<7) { index in
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                checkedDays[index] ?
                                                Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                (index <= todayIndex ? 
                                                 Color(red: 0.25, green: 0.08, blue: 0.08) :
                                                 Color(red: 0.1, green: 0.1, blue: 0.1))
                                            )
                                            .frame(width: 32, height: 32)
                                        
                                        // Today indicator
                                        if index == todayIndex {
                                            Circle()
                                                .stroke(
                                                    checkedDays[index] ?
                                                    Color(red: 0.3, green: 0.7, blue: 0.4) :
                                                    Color(red: 0.8, green: 0.3, blue: 0.3),
                                                    lineWidth: 2
                                                )
                                                .frame(width: 36, height: 36)
                                                .scaleEffect(floatingAnimation ? 1.1 : 1.0)
                                                .opacity(floatingAnimation ? 0.6 : 1.0)
                                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingAnimation)
                                        }
                                        
                                        if checkedDays[index] {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        } else if index <= todayIndex {
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
                                            (index <= todayIndex ? 
                                             Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.6) :
                                             .gray.opacity(0.5))
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .opacity(index > todayIndex ? 0.5 : 1.0)
                            }
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
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                    
                    // Days Counter Card
                    VStack(spacing: 12) {
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
                    .padding(.vertical, 32)
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
                    VStack(spacing: 12) {
                        HStack {
                            Text("Milestones")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int((Double(calculatedDaysClean) / 30.0) * 100))% to month")
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
                    VStack(spacing: 12) {
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
                            icon: "leaf.slash",
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
                    
                    // Action Buttons - Part of Content
                    VStack(spacing: 12) {
                        // Daily Check-In Button
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
                        
                        // Quick Actions
                        HStack(spacing: 8) {
                            QuickActionPill(icon: "wind", text: "Breathe", action: { showingBreathe = true })
                            QuickActionPill(icon: "book.fill", text: "Journal", action: { showingJournal = true })
                            QuickActionPill(icon: "phone.fill", text: "Call", action: { showingContacts = true })
                            QuickActionPill(icon: "lightbulb.fill", text: "Tips", action: { showingTips = true })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                    
                    // Extra padding to account for floating emergency button and tab bar
                    Spacer(minLength: 180)
                }
            }
        }
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
            }

            reconcileStreakIfNeeded()
            
            withAnimation(.easeOut(duration: 0.5)) {
                animateGradient = true
                showContent = true
                floatingAnimation = true
            }
            
            // Update values
            daysClean = calculatedDaysClean
            animateDaysClean(to: calculatedDaysClean)
        }
        .onChange(of: checkInStreak) { newValue in
            daysClean = max(newValue, 0)
            animateDaysClean(to: newValue)
        }
        .onDisappear {
            daysCountTask?.cancel()
            daysCountTask = nil
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
            if checkInStreak != 0 {
                checkInStreak = 0
            }
            return
        }

        let formatter = ISO8601DateFormatter()
        // Validate date format
        guard let lastDate = formatter.date(from: lastCheckInDateString) else {
            // Invalid date format - reset streak for safety
            checkInStreak = 0
            return
        }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastDate)
        let today = calendar.startOfDay(for: Date())
        let delta = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        // Streak grace period: Allow 1 missed day (48 hours) before breaking streak
        // This is more forgiving for users who might miss a single day
        let gracePeriodDays = 2 // User has up to 2 days to check in
        
        if delta > gracePeriodDays && checkInStreak != 0 {
            // Streak breaks after missing more than 1 day
            checkInStreak = 0
        }
    }
}

// New supporting views
struct HeroOrbView: View {
    @Binding var animating: Bool
    
    var body: some View {
        ZStack {
            // HUGE vibrant orb like Quittr
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.3),  // Bright gold
                            Color(red: 0.95, green: 0.6, blue: 0.2), // Orange
                            Color(red: 0.9, green: 0.4, blue: 0.25), // Deep orange
                            Color(red: 0.85, green: 0.3, blue: 0.3).opacity(0.8), // Pink-red
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 420, height: 420)
                .blur(radius: 20)
                .opacity(0.5) // High opacity for vibrancy
                .position(x: UIScreen.main.bounds.width - 100, y: 150)
                .rotationEffect(.degrees(animating ? 360 : 0))
                .animation(.linear(duration: 90).repeatForever(autoreverses: false), value: animating)
            
            // Inner glow for more vibrancy
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 15)
                .position(x: UIScreen.main.bounds.width - 100, y: 150)
                .scaleEffect(animating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animating)
        }
    }
}

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

// Preference key for tracking scroll position
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
                bounceTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
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
            startAnimation()
        }
    }
    
    func startAnimation() {
        // Create falling leaves
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                let leaf = LeafParticle(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: -50,
                    rotation: Double.random(in: 0...360),
                    scale: CGFloat.random(in: 0.6...1.2),
                    opacity: Double.random(in: 0.6...1.0)
                )
                leafParticles.append(leaf)
                
                // Animate leaf falling
                withAnimation(.easeIn(duration: 2.5)) {
                    if let index = leafParticles.firstIndex(where: { $0.id == leaf.id }) {
                        leafParticles[index].y = UIScreen.main.bounds.height + 100
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
