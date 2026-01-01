//
//  NotificationManager.swift
//  Offleaf
//
//  Created by Assistant on 10/21/25.
//

import SwiftUI
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    private let defaults = UserDefaults.standard

    private enum StorageKey {
        static let permissionAsked = "notificationPermissionAsked"
        static let permissionGranted = "notificationPermissionGranted"
        static let lastScheduledMilestone = "lastScheduledMilestone"
        static let lastCheckInDate = "lastCheckInDate"
        static let dailyCheckInEnabled = "dailyCheckInEnabled"
        static let motivationalQuotesEnabled = "motivationalQuotesEnabled"
        static let milestoneRemindersEnabled = "milestoneRemindersEnabled"
        static let cravingTipsEnabled = "cravingTipsEnabled"
        static let checkInTime = "checkInTime"
    }

    private var permissionAsked: Bool {
        get { defaults.bool(forKey: StorageKey.permissionAsked) }
        set { defaults.set(newValue, forKey: StorageKey.permissionAsked) }
    }

    private var permissionGranted: Bool {
        get { defaults.bool(forKey: StorageKey.permissionGranted) }
        set { defaults.set(newValue, forKey: StorageKey.permissionGranted) }
    }

    private var lastScheduledMilestone: Int {
        get { defaults.integer(forKey: StorageKey.lastScheduledMilestone) }
        set { defaults.set(newValue, forKey: StorageKey.lastScheduledMilestone) }
    }

    private var lastCheckInDate: String {
        get { defaults.string(forKey: StorageKey.lastCheckInDate) ?? "" }
        set { defaults.set(newValue, forKey: StorageKey.lastCheckInDate) }
    }
    
    // Notification settings
    private var dailyCheckInEnabled: Bool {
        get { defaults.object(forKey: StorageKey.dailyCheckInEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: StorageKey.dailyCheckInEnabled) }
    }

    private var motivationalQuotesEnabled: Bool {
        get { defaults.object(forKey: StorageKey.motivationalQuotesEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: StorageKey.motivationalQuotesEnabled) }
    }

    private var milestoneRemindersEnabled: Bool {
        get { defaults.object(forKey: StorageKey.milestoneRemindersEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: StorageKey.milestoneRemindersEnabled) }
    }

    private var cravingTipsEnabled: Bool {
        get { defaults.object(forKey: StorageKey.cravingTipsEnabled) as? Bool ?? false }
        set { defaults.set(newValue, forKey: StorageKey.cravingTipsEnabled) }
    }

    private var checkInTimeString: String {
        get { defaults.string(forKey: StorageKey.checkInTime) ?? "09:00" }
        set { defaults.set(newValue, forKey: StorageKey.checkInTime) }
    }

    private var motivationQuoteIndex: Int {
        get { defaults.integer(forKey: "motivationQuoteIndex") }
        set { defaults.set(newValue, forKey: "motivationQuoteIndex") }
    }
    
    private override init() {
        super.init()
        migrateLegacyCheckInTime()
        checkPermissionStatus()
    }
    
    // MARK: - Permission Management
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
                self.permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    private func migrateLegacyCheckInTime() {
        if checkInTimeString == "20:00" {
            checkInTimeString = "09:00"
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.permissionAsked = true
                self.permissionGranted = granted
                self.checkPermissionStatus()
            }
            
            if granted {
                await scheduleInitialNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleInitialNotifications(clearExisting: Bool = true) async {
        if clearExisting {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        if dailyCheckInEnabled {
            scheduleDailyCheckIn()
        }
        
        if milestoneRemindersEnabled {
            await scheduleMilestoneNotifications()
        }
        
        if motivationalQuotesEnabled {
            await scheduleMotivationalQuotes()
        }
        
        if cravingTipsEnabled {
            scheduleCravingSupport()
        }
    }
    
    func scheduleDailyCheckIn() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Log your mood and track your progress."
        content.sound = .default
        content.categoryIdentifier = "DAILY_CHECKIN" // Category for notification actions
        content.userInfo = ["type": "dailyCheckIn"] // Add metadata for handling
        
        // Parse the time from settings
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let checkInTime = formatter.date(from: checkInTimeString) else {
            print("Warning: Invalid check-in time format: \(checkInTimeString)")
            // Fall back to default 9 AM time
            return
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: checkInTime)
        let minute = calendar.component(.minute, from: checkInTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily check-in: \(error)")
            }
        }
    }
    
    func scheduleMilestoneNotifications() async {
        guard let quitDateString = UserDefaults.standard.string(forKey: "quitDate"),
              let quitDate = ISO8601DateFormatter().date(from: quitDateString) else { return }
        
        let milestones = milestoneDays
        let calendar = Calendar.current
        
        for milestone in milestones {
            guard milestone > lastScheduledMilestone else { continue }
            
            if let milestoneDate = calendar.date(byAdding: .day, value: milestone, to: quitDate) {
                // For past milestones, schedule a "catch-up" notification
                let now = Date()
                let notificationDate: Date
                
                if milestoneDate <= now {
                    // Milestone already passed - schedule for next available time (1 hour from now)
                    notificationDate = now.addingTimeInterval(3600)
                } else {
                    // Future milestone - schedule normally
                    notificationDate = milestoneDate
                }
                
                let content = UNMutableNotificationContent()
                content.title = "🎉 Milestone Achieved!"
                content.body = getMilestoneMessage(for: milestone)
                content.sound = .default
                content.categoryIdentifier = "MILESTONE"
                content.userInfo = ["milestone": milestone]
                
                // Schedule notification
                var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                if notificationDate != milestoneDate {
                    // For catch-up notifications, use the calculated time
                    dateComponents.hour = calendar.component(.hour, from: notificationDate)
                    dateComponents.minute = calendar.component(.minute, from: notificationDate)
                } else {
                    // For future milestones, schedule at 10 AM
                    dateComponents.hour = 10
                    dateComponents.minute = 0
                }
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "milestone-\(milestone)",
                    content: content,
                    trigger: trigger
                )
                
                do {
                    try await addNotificationRequest(request)
                    await MainActor.run {
                        self.lastScheduledMilestone = milestone
                    }
                } catch {
                    print("Error scheduling milestone \(milestone): \(error)")
                }
            }
        }
    }
    
    func scheduleMotivationalQuotes() async {
        let quotes = [
            "Every joint you put down is a win.",
            "Your future self is grateful for every clear-headed day.",
            "You're stronger than the cravings.",
            "Remember why you started this journey.",
            "Each day gets a little easier.",
            "You're gaining clarity, not losing anything.",
            "Your future self will thank you.",
            "Breaking free feels amazing, doesn't it?",
            "You're writing a new chapter in your life.",
            "Keep going. You've got this!"
        ]
        
        let daysAhead = 30
        let center = UNUserNotificationCenter.current()
        let identifiers = (0..<daysAhead).map { "daily-motivation-\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        let calendar = Calendar.current
        let baseIndex = motivationQuoteIndex % quotes.count

        for offset in 0..<daysAhead {
            guard let fireDate = calendar.date(byAdding: .day, value: offset, to: Date()) else { continue }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: fireDate)
            dateComponents.hour = 14
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "Daily Motivation"
            content.body = quotes[(baseIndex + offset) % quotes.count]
            content.sound = .default
            content.categoryIdentifier = "MOTIVATION"

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifiers[offset],
                content: content,
                trigger: trigger
            )

            do {
                try await addNotificationRequest(request)
            } catch {
                print("Error scheduling motivational quote: \(error)")
            }
        }

        await MainActor.run {
            self.motivationQuoteIndex = (baseIndex + daysAhead) % quotes.count
        }
    }
    
    func scheduleCravingSupport() {
        // Schedule support notifications at typical craving times
        // These are configurable defaults based on common craving patterns
        let morningHour = 9
        let afternoonHour = 15
        let eveningHour = 20
        
        let cravingTimes = [
            (hour: morningHour, minute: 0, message: "Morning craving? Try a quick walk or breathing exercise."),
            (hour: afternoonHour, minute: 30, message: "Afternoon slump? You're stronger than this craving!"),
            (hour: eveningHour, minute: 0, message: "Evening craving? Remember how far you've come today.")
        ]
        
        for (index, time) in cravingTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Craving Support"
            content.body = time.message
            content.sound = .default
            content.categoryIdentifier = "CRAVING_SUPPORT"
            
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "craving-support-\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling craving support: \(error)")
                }
            }
        }
    }
    
    // MARK: - Update Methods
    
    func updateDailyCheckInTime(_ timeString: String) {
        checkInTimeString = timeString
        
        // Cancel existing daily check-in
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
        
        // Reschedule if enabled
        if dailyCheckInEnabled {
            scheduleDailyCheckIn()
        }
    }
    
    func toggleDailyCheckIn(_ enabled: Bool) {
        dailyCheckInEnabled = enabled
        
        if enabled {
            scheduleDailyCheckIn()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
        }
    }
    
    func toggleMotivationalQuotes(_ enabled: Bool) {
        motivationalQuotesEnabled = enabled
        
        if enabled {
            Task {
                await self.scheduleMotivationalQuotes()
            }
        } else {
            let daysAhead = 30
            let identifiers = (0..<daysAhead).map { "daily-motivation-\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func toggleMilestoneReminders(_ enabled: Bool) {
        milestoneRemindersEnabled = enabled
        
        if enabled {
            Task {
                await scheduleMilestoneNotifications()
            }
        } else {
            // Remove all milestone notifications
            let identifiers = milestoneDays.map { "milestone-\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func toggleCravingSupport(_ enabled: Bool) {
        cravingTipsEnabled = enabled
        
        if enabled {
            scheduleCravingSupport()
        } else {
            let identifiers = (0..<3).map { "craving-support-\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMilestoneMessage(for days: Int) -> String {
        switch days {
        case 1:
            return "Day one cannabis-free! The hardest step is behind you."
        case 3:
            return "3 days clear! THC is already leaving your system—keep going!"
        case 7:
            return "One week without cannabis! Feel the clarity building. 🏆"
        case 14:
            return "Two weeks! Your focus and sleep are finding a new rhythm."
        case 21:
            return "21 days! You've built healthier routines around cravings."
        case 30:
            return "One month cannabis-free! Your mind and motivation are leveling up."
        case 60:
            return "Two months! You're saving serious money and keeping your goals on track."
        case 90:
            return "90 days cannabis-free! Celebrate this huge milestone."
        case 180:
            return "Six months! Your drive is stronger than ever—keep investing in yourself."
        case 365:
            return "ONE YEAR CANNABIS-FREE! 🎊 You've transformed your lifestyle."
        default:
            return "Another milestone reached! You're doing amazing!"
        }
    }
    
    func checkAndRescheduleMissedMilestones() {
        guard let quitDateString = UserDefaults.standard.string(forKey: "quitDate"),
              let quitDate = ISO8601DateFormatter().date(from: quitDateString) else { return }
        
        // Match HomeView's daysSinceQuit calculation (1-based counting)
        let calendar = Calendar.current
        let startOfQuitDate = calendar.startOfDay(for: quitDate)
        let startOfToday = calendar.startOfDay(for: Date())
        
        let daysSinceQuit: Int
        if startOfQuitDate > startOfToday {
            daysSinceQuit = 0
        } else {
            let days = calendar.dateComponents([.day], from: startOfQuitDate, to: startOfToday).day ?? 0
            daysSinceQuit = max(1, days + 1)
        }
        
        // Update last scheduled milestone if needed
        if daysSinceQuit > lastScheduledMilestone {
            Task {
                await scheduleMilestoneNotifications()
            }
        }
    }

    func resetProgressNotifications() async {
        lastScheduledMilestone = 0
        motivationQuoteIndex = 0
        let milestoneIdentifiers = milestoneDays.map { "milestone-\($0)" }
        let motivationIdentifiers = (0..<30).map { "daily-motivation-\($0)" }
        let cravingIdentifiers = (0..<3).map { "craving-support-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: milestoneIdentifiers + motivationIdentifiers + cravingIdentifiers)
        await scheduleInitialNotifications(clearExisting: false)
    }
    
    func refreshScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasCheckIn = requests.contains { $0.identifier == "daily-checkin" }
            if !hasCheckIn && self.dailyCheckInEnabled {
                self.scheduleDailyCheckIn()
            }
        }
    }
    
    func scheduleAllNotifications() {
        if dailyCheckInEnabled {
            scheduleDailyCheckIn()
        }
        
        if motivationalQuotesEnabled {
            Task {
                await scheduleMotivationalQuotes()
            }
        }
        
        if milestoneRemindersEnabled {
            Task {
                await scheduleMilestoneNotifications()
            }
        }
        
        if cravingTipsEnabled {
            scheduleCravingSupport()
        }
    }
    
    func scheduleCheckInReminderIfNeeded() {
        guard dailyCheckInEnabled else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let components = checkInTimeString.split(separator: ":")
        
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        guard let checkInTime = calendar.date(from: dateComponents) else { return }
        
        if checkInTime > now {
            let content = UNMutableNotificationContent()
            content.title = "Time for Your Check-In"
            content.body = "Let's see how you're doing today!"
            content.sound = .default
            content.categoryIdentifier = "DAILY_CHECKIN"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: checkInTime.timeIntervalSince(now),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "daily-checkin-reminder",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling check-in reminder: \(error)")
                }
            }
        }
    }

    private func addNotificationRequest(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private var milestoneDays: [Int] {
        [1, 3, 7, 14, 21, 30, 60, 90, 180, 365]
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        switch categoryIdentifier {
        case "DAILY_CHECKIN":
            // Open daily check-in view
            NotificationCenter.default.post(name: Notification.Name("OpenDailyCheckIn"), object: nil)
            
        case "MILESTONE":
            // Show celebration
            if let milestone = response.notification.request.content.userInfo["milestone"] as? Int {
                NotificationCenter.default.post(
                    name: Notification.Name("CelebrateMilestone"),
                    object: nil,
                    userInfo: ["milestone": milestone]
                )
            }
            
        default:
            break
        }
    }
}
