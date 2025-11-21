//
//  NotificationsSettingsView.swift
//  Offleaf
//

import SwiftUI
import UserNotifications
import UIKit

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("dailyCheckInEnabled") private var dailyCheckInEnabled = true
    @AppStorage("motivationalQuotesEnabled") private var motivationalQuotesEnabled = true
    @AppStorage("milestoneRemindersEnabled") private var milestoneRemindersEnabled = true
    @AppStorage("cravingTipsEnabled") private var cravingTipsEnabled = false
    @AppStorage("checkInTime") private var checkInTimeString = "09:00"
    
    @State private var checkInTime = Date()
    @State private var showPermissionAlert = false
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Notification Permission Status
                        if notificationManager.permissionStatus != .authorized {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.yellow)
                                    
                                    Text("Notifications are disabled")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                Button(action: openSettings) {
                                    Text("Enable in Settings")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.1))
                            )
                        }
                        
                        // Daily Check-in
                        VStack(spacing: 16) {
                            Toggle(isOn: $dailyCheckInEnabled.onChange { enabled in
                                notificationManager.toggleDailyCheckIn(enabled)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Check-in")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Remind me to log my mood and cravings")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                            
                            if dailyCheckInEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Check-in Time")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    DatePicker("", selection: $checkInTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .frame(height: 120)
                                        .onChange(of: checkInTime) { oldValue, newValue in
                                            saveCheckInTime(newValue)
                                            notificationManager.updateDailyCheckInTime(checkInTimeString)
                                        }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Other Notifications
                        VStack(spacing: 20) {
                            Toggle(isOn: $motivationalQuotesEnabled.onChange { enabled in
                                notificationManager.toggleMotivationalQuotes(enabled)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Motivational Quotes")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Daily inspiration to keep you going")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            Toggle(isOn: $milestoneRemindersEnabled.onChange { enabled in
                                notificationManager.toggleMilestoneReminders(enabled)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Milestone Reminders")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Celebrate your achievements")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            Toggle(isOn: $cravingTipsEnabled.onChange { enabled in
                                notificationManager.toggleCravingSupport(enabled)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Craving Management Tips")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Get tips when cravings are typically high")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                            
                            Text("You can change your notification preferences in Settings > Notifications > Offleaf")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.4, green: 0.6, blue: 1).opacity(0.1))
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadCheckInTime()
            notificationManager.checkPermissionStatus()
            notificationManager.checkAndRescheduleMissedMilestones()
        }
    }
    
    private func loadCheckInTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let time = formatter.date(from: checkInTimeString) {
            checkInTime = time
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            checkInTime = Calendar.current.date(from: components) ?? Date()
            saveCheckInTime(checkInTime)
        }
    }
    
    private func saveCheckInTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        checkInTimeString = formatter.string(from: date)
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// Extension to handle toggle onChange
extension Binding where Value == Bool {
    func onChange(_ handler: @escaping (Bool) -> Void) -> Binding<Bool> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}
