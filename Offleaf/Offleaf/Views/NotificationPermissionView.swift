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
            // Gradient background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.1, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button at top
                HStack {
                    Spacer()
                    Button(action: onSkip) {
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            // Icon and title
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2),
                                                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                            }
                            
                            VStack(spacing: 12) {
                                Text("Stay on Track")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("with Smart Reminders")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Personalized notifications to support your journey")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Benefits
                        VStack(spacing: 20) {
                            NotificationBenefitRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Daily Check-ins",
                                subtitle: "Track your mood and progress",
                                iconColor: Color(red: 0.4, green: 0.6, blue: 1)
                            )
                            
                            NotificationBenefitRow(
                                icon: "trophy.fill",
                                title: "Milestone Celebrations",
                                subtitle: "Get your 7-day badge on \(firstMilestoneDate)",
                                iconColor: Color(red: 0.9, green: 0.7, blue: 0.3)
                            )
                            
                            NotificationBenefitRow(
                                icon: "heart.fill",
                                title: "Craving Support",
                                subtitle: "Help when you need it most",
                                iconColor: Color(red: 0.9, green: 0.3, blue: 0.4)
                            )
                        }
                        .padding(.horizontal, 24)

                        // Time picker section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose your daily check-in time")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Button(action: {
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

                            if showTimePickerStored {
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(height: 150)
                                    .id("timePickerSection")
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        .padding(.horizontal, 24)

                        // Enable button
                        VStack(spacing: 16) {
                            Button(action: {
                                requestPermission()
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
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color.white.opacity(0.9)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(28)
                            }
                            .disabled(permissionRequested)
                            
                            Text("You can change this anytime in Settings")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.8))
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
        
        if notificationManager.permissionStatus == .denied {
            permissionAlertMessage = "Notifications are currently turned off. Enable them in Settings to receive reminders."
            showOpenSettingsButton = true
            showPermissionAlert = true
            return
        }
        
        permissionRequested = true
        
        Task {
            let granted = await notificationManager.requestPermission()
            
            await MainActor.run {
                permissionRequested = false
                if granted {
                    showOpenSettingsButton = false
                    showPermissionAlert = false
                    onComplete()
                } else {
                    permissionAlertMessage = "We couldn't enable notifications right now. You can turn them on later from Settings."
                    showOpenSettingsButton = notificationManager.permissionStatus == .denied
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
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
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