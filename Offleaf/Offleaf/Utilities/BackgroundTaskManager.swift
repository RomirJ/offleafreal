//
//  BackgroundTaskManager.swift
//  Offleaf
//
//  Background task scheduling for periodic updates
//

import BackgroundTasks
import SwiftUI
import UserNotifications

// Actor to handle task completion in async-safe manner
actor TaskCompletionActor {
    private var isCompleted = false
    
    func markCompleted() -> Bool {
        if !isCompleted {
            isCompleted = true
            return true
        }
        return false
    }
}

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let backgroundTaskIdentifier = "com.offleaf.refresh"
    private let notificationTaskIdentifier = "com.offleaf.notifications"
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task, expectedType: BGAppRefreshTask.self)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: notificationTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task, expectedType: BGProcessingTask.self)
        }
    }
    
    private func handleBackgroundTask<T: BGTask>(_ task: BGTask, expectedType: T.Type) {
        guard let typedTask = task as? T else {
            let errorMessage = "Background task type mismatch: Expected \(T.self) but received \(type(of: task)) for identifier \(task.identifier)"
            print("[BackgroundTaskManager] ERROR: \(errorMessage)")
            
            // Report to analytics if available
            #if DEBUG
            assertionFailure(errorMessage)
            #endif
            
            // Complete the task as failed to prevent iOS from penalizing the app
            task.setTaskCompleted(success: false)
            return
        }
        
        // Route to appropriate handler based on type
        switch typedTask {
        case let appRefreshTask as BGAppRefreshTask:
            handleAppRefresh(task: appRefreshTask)
        case let processingTask as BGProcessingTask:
            handleNotificationRefresh(task: processingTask)
        default:
            print("[BackgroundTaskManager] WARNING: Unhandled task type \(type(of: typedTask))")
            task.setTaskCompleted(success: false)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            #if DEBUG
            print("[BackgroundTaskManager] Failed to schedule app refresh: \(error)")
            #endif
        }
    }
    
    func scheduleNotificationRefresh() {
        let request = BGProcessingTaskRequest(identifier: notificationTaskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            #if DEBUG
            print("[BackgroundTaskManager] Failed to schedule notification refresh: \(error)")
            #endif
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let taskCompletionActor = TaskCompletionActor()
        
        Task {
            // Set up expiration handler
            task.expirationHandler = {
                Task {
                    let completed = await taskCompletionActor.markCompleted()
                    if completed {
                        task.setTaskCompleted(success: false)
                    }
                }
            }
            
            // Perform the background work
            await MainActor.run {
                StreakManager.shared.validateStreak()
                
                if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                    let lastCheckIn = UserDefaults.standard.string(forKey: "lastCheckInDate") ?? ""
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    let today = formatter.string(from: Date())
                    if lastCheckIn != today {
                        NotificationManager.shared.scheduleCheckInReminderIfNeeded()
                    }
                }
            }
            
            // Mark task as completed
            let completed = await taskCompletionActor.markCompleted()
            if completed {
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    private func handleNotificationRefresh(task: BGProcessingTask) {
        scheduleNotificationRefresh()
        
        let taskCompletionActor = TaskCompletionActor()
        
        Task {
            // Set up expiration handler
            task.expirationHandler = {
                Task {
                    let completed = await taskCompletionActor.markCompleted()
                    if completed {
                        task.setTaskCompleted(success: false)
                    }
                }
            }
            
            // Perform the background work
            await MainActor.run {
                NotificationManager.shared.checkAndRescheduleMissedMilestones()
                NotificationManager.shared.refreshScheduledNotifications()
                
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                if hasCompletedOnboarding {
                    NotificationManager.shared.scheduleAllNotifications()
                }
            }
            
            // Mark task as completed
            let completed = await taskCompletionActor.markCompleted()
            if completed {
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}