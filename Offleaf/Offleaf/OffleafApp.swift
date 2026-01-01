//
//  OffleafApp.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI
import UserNotifications
import BackgroundTasks

@main
struct OffleafApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.scenePhase) var scenePhase
    private let notificationManager = NotificationManager.shared
    private let backgroundTaskManager = BackgroundTaskManager.shared
    
    init() {
        setupNotifications()
        setupBackgroundTasks()
        // Migrate dates from UTC to local timezone if needed
        DateMigrationHelper.migrateIfNeeded()
        
        // Force portrait orientation
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    SplashScreenView()
                }
            }
            .onAppear {
                // Check for missed milestones when app launches
                notificationManager.checkAndRescheduleMissedMilestones()
                // Validate streak when app launches
                StreakManager.shared.validateStreak()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .background:
                    // Schedule background tasks when entering background
                    backgroundTaskManager.scheduleAppRefresh()
                    backgroundTaskManager.scheduleNotificationRefresh()
                case .active:
                    // Validate streak when becoming active
                    StreakManager.shared.validateStreak()
                default:
                    break
                }
            }
        }
    }
    
    private func setupBackgroundTasks() {
        backgroundTaskManager.registerBackgroundTasks()
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        // Define notification actions
        let checkInAction = UNNotificationAction(
            identifier: "CHECK_IN_ACTION",
            title: "Check In Now",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Remind in 1 Hour",
            options: []
        )
        
        // Create categories
        let checkInCategory = UNNotificationCategory(
            identifier: "DAILY_CHECKIN",
            actions: [checkInAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let milestoneCategory = UNNotificationCategory(
            identifier: "MILESTONE",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let motivationCategory = UNNotificationCategory(
            identifier: "MOTIVATION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let cravingSupportCategory = UNNotificationCategory(
            identifier: "CRAVING_SUPPORT",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([
            checkInCategory,
            milestoneCategory,
            motivationCategory,
            cravingSupportCategory
        ])
    }
}
