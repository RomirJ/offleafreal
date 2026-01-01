//
//  NotificationPermissionView.swift
//  Offleaf
//
//  Created by Assistant on 10/21/25.
//

import SwiftUI
import UIKit

struct NotificationPermissionView: View {
    @AppStorage("checkInTime") private var checkInTimeString = "09:00"
    @AppStorage("quitDate") private var quitDateString = ""
    @State private var selectedTime = Date()
    @State private var permissionRequested = false
    @State private var showTimePickerStored = false
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var showOpenSettingsButton = false
    @Environment(\.scenePhase) var scenePhase
    
    // Animation states
    @State private var showBellIcon = false
    @State private var bellScale: CGFloat = 0
    @State private var bellRotation: Double = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showBenefits: [Bool] = Array(repeating: false, count: 3)
    @State private var showTimePicker = false
    @State private var showEnableButton = false
    @State private var showMaybeButton = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var maybeButtonScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var backgroundGradientOffset: CGFloat = 0
    
    var onComplete: () -> Void
    var onSkip: () -> Void
    
    // Calculate first milestone
    private var firstMilestoneDate: String {
        guard let quitDate = ISO8601DateFormatter().date(from: quitDateString) else {
            return "in 7 days"
        }
        
        let sevenDaysFromQuit = Calendar.current.date(byAdding: .day, value: 7, to: quitDate) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: sevenDaysFromQuit)
    }
    
    var body: some View {
        return ZStack {
            // Animated gradient background
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.1, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Animated radial gradient
                RadialGradient(
                    colors: [
                        Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
                .offset(y: backgroundGradientOffset)
                .opacity(glowOpacity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: backgroundGradientOffset)
            }
            
            VStack(spacing: 0) {
                // Skip button at top
                HStack {
                    Spacer()
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showBellIcon = false
                            showTitle = false
                            showSubtitle = false
                            showBenefits = Array(repeating: false, count: 3)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onSkip()
                        }
                    }) {
                        Text("Maybe Later")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .scaleEffect(maybeButtonScale)
                    .opacity(showMaybeButton ? 1 : 0)
                    .offset(y: showMaybeButton ? 0 : -10)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            maybeButtonScale = pressing ? 0.95 : 1.0
                        }
                    })
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            // Icon and title
                            VStack(spacing: 20) {
                                ZStack {
                                    // Pulsing background circle
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15),
                                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .scaleEffect(pulseScale)
                                        .opacity(showBellIcon ? 1 : 0)
                                    
                                    // Main bell background
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(bellScale)
                                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 20, x: 0, y: 10)
                                    
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 45))
                                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                        .scaleEffect(bellScale)
                                        .rotationEffect(.degrees(bellRotation))
                                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5), radius: 10)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Stay on Track")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(showTitle ? 1 : 0)
                                    .offset(y: showTitle ? 0 : 20)
                                
                                Text("with Smart Reminders")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(showTitle ? 1 : 0)
                                    .offset(y: showTitle ? 0 : 20)
                                
                                Text("Personalized notifications to support your journey")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                                    .opacity(showSubtitle ? 1 : 0)
                                    .offset(y: showSubtitle ? 0 : 10)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Benefits
                        VStack(spacing: 20) {
                            NotificationBenefitRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Daily Check-ins",
                                subtitle: "Track your mood and progress",
                                iconColor: Color(red: 0.4, green: 0.6, blue: 1),
                                isShowing: showBenefits[0]
                            )
                            
                            NotificationBenefitRow(
                                icon: "trophy.fill",
                                title: "Milestone Celebrations",
                                subtitle: "Get your 7-day badge on \(firstMilestoneDate)",
                                iconColor: Color(red: 0.9, green: 0.7, blue: 0.3),
                                isShowing: showBenefits[1]
                            )
                            
                            NotificationBenefitRow(
                                icon: "heart.fill",
                                title: "Craving Support",
                                subtitle: "Help when you need it most",
                                iconColor: Color(red: 0.9, green: 0.3, blue: 0.4),
                                isShowing: showBenefits[2]
                            )
                        }
                        .padding(.horizontal, 24)

                        // Time picker section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose your daily check-in time")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(showTimePicker ? 1 : 0)
                                .offset(x: showTimePicker ? 0 : -20)
                            
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showTimePickerStored.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                                    
                                    Text(formatTime(selectedTime))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showTimePickerStored ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .opacity(showTimePicker ? 1 : 0)
                            .scaleEffect(showTimePicker ? 1 : 0.9)

                            if showTimePickerStored {
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(height: 150)
                                    .id("timePickerSection")
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                                        removal: .scale(scale: 0.95).combined(with: .opacity)
                                    ))
                                    .onChange(of: selectedTime) { _, _ in
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                    }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Enable button
                        VStack(spacing: 16) {
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    buttonScale = 0.97
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        buttonScale = 1.0
                                    }
                                    requestPermission()
                                }
                            }) {
                                HStack {
                                    if permissionRequested {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 18))
                                        Text("Enable Notifications")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    ZStack {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.85, blue: 0.5),
                                                Color(red: 0.35, green: 0.75, blue: 0.45)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        
                                        // Shimmer effect
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0),
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .offset(x: showEnableButton ? 200 : -200)
                                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: showEnableButton)
                                    }
                                )
                                .cornerRadius(28)
                                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 15, x: 0, y: 5)
                            }
                            .scaleEffect(buttonScale)
                            .opacity(showEnableButton ? 1 : 0)
                            .offset(y: showEnableButton ? 0 : 20)
                            .disabled(permissionRequested)
                            
                            Text("You can change this anytime in Settings")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.8))
                                .opacity(showEnableButton ? 1 : 0)
                                .animation(.easeOut(duration: 0.3).delay(0.2), value: showEnableButton)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .padding(.bottom, showTimePickerStored ? 220 : 140)
                    }
                }
                // End ScrollViewReader
            }
        }
        .onAppear {
            loadCheckInTime()
            notificationManager.checkPermissionStatus()
            
            // Trigger entrance animations
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                bellScale = 1.0
                showBellIcon = true
            }
            
            // Bell rotation animation
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                bellRotation = -10
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                bellRotation = 10
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.7)) {
                bellRotation = 0
            }
            
            // Pulse animation for bell background
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1)) {
                pulseScale = 1.1
            }
            
            // Show title and subtitle
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                showTitle = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6)) {
                showSubtitle = true
            }
            
            // Show benefits with stagger
            for index in 0..<3 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(Double(index) * 0.1 + 0.8)) {
                    showBenefits[index] = true
                }
            }
            
            // Show time picker
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.2)) {
                showTimePicker = true
            }
            
            // Show buttons
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(1.4)) {
                showEnableButton = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                showMaybeButton = true
            }
            
            // Background glow animation
            withAnimation(.easeOut(duration: 1).delay(0.5)) {
                glowOpacity = 1.0
            }
            
            // Start background gradient animation
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                backgroundGradientOffset = 50
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh permission status when returning from Settings
                notificationManager.checkPermissionStatus()
                
                // If permission was granted while in Settings, auto-proceed
                if notificationManager.permissionStatus == .authorized && showPermissionAlert {
                    showPermissionAlert = false
                    onComplete()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: showTimePickerStored ? 40 : 16)
        }
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            if showOpenSettingsButton {
                Button("Open Settings") {
                    openAppSettings()
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(permissionAlertMessage)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func loadCheckInTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        if checkInTimeString == "20:00" {
            checkInTimeString = "09:00"
        }

        if let time = formatter.date(from: checkInTimeString) {
            selectedTime = time
        } else {
            // Default to 9 AM
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            selectedTime = Calendar.current.date(from: components) ?? Date()
            saveCheckInTime(selectedTime)
        }
    }
    
    private func saveCheckInTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        checkInTimeString = formatter.string(from: date)
    }
    
    private func requestPermission() {
        // Save the selected time before requesting permission
        saveCheckInTime(selectedTime)
        
        // Don't pre-check permission status - let requestPermission handle it
        permissionRequested = true
        
        Task {
            // Always attempt to request permission
            // If already denied, this will return false immediately
            // If not determined, this will show the iOS dialog
            // If already authorized, this will return true immediately
            let granted = await notificationManager.requestPermission()
            
            await MainActor.run {
                permissionRequested = false
                
                // Re-check current status after request attempt
                notificationManager.checkPermissionStatus()
                
                if granted {
                    showOpenSettingsButton = false
                    showPermissionAlert = false
                    
                    // Success animation
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        bellScale = 1.2
                        bellRotation = 360
                    }
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.2)) {
                        bellScale = 1.0
                        showBellIcon = false
                        showTitle = false
                        showSubtitle = false
                        showBenefits = Array(repeating: false, count: 3)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                } else {
                    // Check the actual current status to show appropriate message
                    if notificationManager.permissionStatus == .denied {
                        permissionAlertMessage = "Notifications are currently turned off. Enable them in Settings to receive reminders."
                        showOpenSettingsButton = true
                    } else {
                        permissionAlertMessage = "We couldn't enable notifications right now. You can turn them on later from Settings."
                        showOpenSettingsButton = false
                    }
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func openAppSettings() {
#if canImport(UIKit)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
#endif
    }
}


struct NotificationBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let isShowing: Bool
    
    @State private var iconScale: CGFloat = 1.0
    @State private var iconRotation: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Gradient background for icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                iconColor.opacity(0.2),
                                iconColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: iconColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(iconScale)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                if isShowing {
                    // Icon entrance animation
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                        iconScale = 1.1
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.3)) {
                        iconScale = 1.0
                    }
                    
                    // Gentle rotation for trophy
                    if icon == "trophy.fill" {
                        withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                            iconRotation = -5
                        }
                        withAnimation(.easeInOut(duration: 0.5).delay(0.4)) {
                            iconRotation = 5
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.6)) {
                            iconRotation = 0
                        }
                    }
                    
                    // Pulse for heart
                    if icon == "heart.fill" {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.5)) {
                            iconScale = 1.15
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .opacity(isShowing ? 1 : 0)
        .offset(x: isShowing ? 0 : -30)
        .scaleEffect(isShowing ? 1 : 0.8, anchor: .leading)
    }
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView(
            onComplete: {},
            onSkip: {}
        )
    }
}