//
//  BackgroundTaskManager.swift
//  Offleaf
//
//  Background task scheduling for periodic updates
//

import BackgroundTasks
import SwiftUI
import UserNotifications

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
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let taskCompletionLock = NSLock()
        var taskCompleted = false
        
        let operation = BlockOperation { [weak self] in
            guard self != nil else {
                taskCompletionLock.lock()
                defer { taskCompletionLock.unlock() }
                if !taskCompleted {
                    taskCompleted = true
                    task.setTaskCompleted(success: false)
                }
                return
            }
            
            Task { @MainActor in
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
                
                taskCompletionLock.lock()
                defer { taskCompletionLock.unlock() }
                if !taskCompleted {
                    taskCompleted = true
                    task.setTaskCompleted(success: true)
                }
            }
        }
        
        task.expirationHandler = { [weak queue, weak operation] in
            queue?.cancelAllOperations()
            taskCompletionLock.lock()
            defer { taskCompletionLock.unlock() }
            if !taskCompleted {
                taskCompleted = true
                task.setTaskCompleted(success: operation?.isCancelled == false)
            }
        }
        
        operation.completionBlock = { [weak operation] in
            taskCompletionLock.lock()
            defer { taskCompletionLock.unlock() }
            if !taskCompleted {
                taskCompleted = true
                task.setTaskCompleted(success: operation?.isCancelled == false)
            }
        }
        
        queue.addOperation(operation)
    }
    
    private func handleNotificationRefresh(task: BGProcessingTask) {
        scheduleNotificationRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let taskCompletionLock = NSLock()
        var taskCompleted = false
        
        let operation = BlockOperation { [weak self] in
            guard self != nil else {
                taskCompletionLock.lock()
                defer { taskCompletionLock.unlock() }
                if !taskCompleted {
                    taskCompleted = true
                    task.setTaskCompleted(success: false)
                }
                return
            }
            
            Task { @MainActor in
                NotificationManager.shared.checkAndRescheduleMissedMilestones()
                NotificationManager.shared.refreshScheduledNotifications()
                
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                if hasCompletedOnboarding {
                    NotificationManager.shared.scheduleAllNotifications()
                }
                
                taskCompletionLock.lock()
                defer { taskCompletionLock.unlock() }
                if !taskCompleted {
                    taskCompleted = true
                    task.setTaskCompleted(success: true)
                }
            }
        }
        
        task.expirationHandler = { [weak queue, weak operation] in
            queue?.cancelAllOperations()
            taskCompletionLock.lock()
            defer { taskCompletionLock.unlock() }
            if !taskCompleted {
                taskCompleted = true
                task.setTaskCompleted(success: operation?.isCancelled == false)
            }
        }
        
        operation.completionBlock = { [weak operation] in
            taskCompletionLock.lock()
            defer { taskCompletionLock.unlock() }
            if !taskCompleted {
                taskCompleted = true
                task.setTaskCompleted(success: operation?.isCancelled == false)
            }
        }
        
        queue.addOperation(operation)
    }
    
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}