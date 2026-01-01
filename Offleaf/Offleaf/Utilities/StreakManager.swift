//
//  StreakManager.swift
//  Offleaf
//
//  Single source of truth for streak calculations
//

import SwiftUI
import Foundation

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    
    @AppStorage("checkInStreak") private var checkInStreak = 0
    @AppStorage("lastCheckInDate") private var lastCheckInDateString = ""
    @AppStorage("longestCheckInStreak") private var longestCheckInStreak = 0
    @AppStorage("totalCheckInDays") private var totalCheckInDays = 0
    @AppStorage("checkInDates") private var checkInDatesString = ""
    
    // Thread-safe serial queue for all streak operations
    private let streakQueue = DispatchQueue(label: "com.offleaf.streakmanager", attributes: .concurrent)
    
    private init() {}
    
    // Single source of truth for current streak
    var currentStreak: Int {
        streakQueue.sync {
            max(checkInStreak, 0)
        }
    }
    
    // Expose longest streak
    var longestStreak: Int {
        streakQueue.sync {
            longestCheckInStreak
        }
    }
    
    // Expose total days
    var totalDays: Int {
        streakQueue.sync {
            totalCheckInDays
        }
    }
    
    // Check if user has checked in today
    var hasCheckedInToday: Bool {
        streakQueue.sync {
            guard !lastCheckInDateString.isEmpty else { return false }
            
            let formatter = ISO8601DateFormatter()
            guard let lastDate = formatter.date(from: lastCheckInDateString) else { return false }
            
            let calendar = Calendar.current
            return calendar.isDateInToday(lastDate)
        }
    }
    
    // Update streak when user checks in
    func recordCheckIn() {
        streakQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let formatter = ISO8601DateFormatter()
            
            // Check if already checked in today (within the barrier)
            guard !self.lastCheckInDateString.isEmpty else {
                // First check-in ever
                DispatchQueue.main.async {
                    self.checkInStreak = 1
                    self.longestCheckInStreak = 1
                    self.lastCheckInDateString = formatter.string(from: today)
                }
                if self.addCheckInDateUnsafe(today) {
                    DispatchQueue.main.async {
                        self.totalCheckInDays += 1
                    }
                }
                return
            }
            
            guard let lastDate = formatter.date(from: self.lastCheckInDateString) else {
                DispatchQueue.main.async {
                    self.checkInStreak = 1
                    self.longestCheckInStreak = max(self.longestCheckInStreak, 1)
                    self.lastCheckInDateString = formatter.string(from: today)
                }
                if self.addCheckInDateUnsafe(today) {
                    DispatchQueue.main.async {
                        self.totalCheckInDays += 1
                    }
                }
                return
            }
            
            // Don't double-check on same day
            if calendar.isDateInToday(lastDate) {
                return
            }
            
            // Calculate new streak based on last check-in
            // Normalize to noon to avoid DST edge cases
            let lastDay = self.normalizeToNoon(calendar.startOfDay(for: lastDate), calendar: calendar)
            let todayNoon = self.normalizeToNoon(today, calendar: calendar)
            let delta = calendar.dateComponents([.day], from: lastDay, to: todayNoon).day ?? 0
            
            let newStreak: Int
            switch delta {
            case 0:
                // Same day - shouldn't happen due to check above
                newStreak = max(self.checkInStreak, 1)
            case 1:
                // Consecutive day - increment streak
                newStreak = self.checkInStreak + 1
            default:
                // Missed days - reset streak
                newStreak = 1
            }
            
            let currentLongest = self.longestCheckInStreak
            
            // Update all properties on main thread
            DispatchQueue.main.async {
                self.checkInStreak = newStreak
                self.longestCheckInStreak = max(currentLongest, newStreak)
                // Update last check-in date
                self.lastCheckInDateString = formatter.string(from: today)
            }
            
            // Add to check-in dates list
            if self.addCheckInDateUnsafe(today) {
                // New day checked in - increment total
                DispatchQueue.main.async {
                    self.totalCheckInDays += 1
                }
            }
        }
    }
    
    // Reset streak (for relapse)
    func resetStreak() {
        streakQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.checkInStreak = 0
                self.lastCheckInDateString = ""
                self.checkInDatesString = ""
                self.longestCheckInStreak = 0
                self.totalCheckInDays = 0
            }
        }
    }
    
    // Check and update streak status (call on app launch/resume)
    func validateStreak() {
        streakQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            guard !self.lastCheckInDateString.isEmpty else { return }
            
            let formatter = ISO8601DateFormatter()
            guard let lastDate = formatter.date(from: self.lastCheckInDateString) else {
                DispatchQueue.main.async {
                    self.checkInStreak = 0
                }
                return
            }
            
            let calendar = Calendar.current
            // Use noon time to avoid DST transitions (which happen at 2-3 AM)
            let today = self.normalizeToNoon(calendar.startOfDay(for: Date()), calendar: calendar)
            let lastDay = self.normalizeToNoon(calendar.startOfDay(for: lastDate), calendar: calendar)
            let delta = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            // Reset streak if more than 1 day has passed
            if delta > 1 {
                DispatchQueue.main.async {
                    self.checkInStreak = 0
                }
            }
        }
    }
    
    // Helper to normalize dates to noon, avoiding DST edge cases
    private func normalizeToNoon(_ date: Date, calendar: Calendar) -> Date {
        // Set time to noon (12:00) to avoid DST transitions at 2-3 AM
        calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
    }
    
    // Thread-unsafe version for internal use within barriers
    private func addCheckInDateUnsafe(_ date: Date) -> Bool {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        // Use local timezone for consistency
        dayFormatter.timeZone = TimeZone.current
        
        let dateString = dayFormatter.string(from: date)
        var dates = checkInDatesString.components(separatedBy: ",").filter { !$0.isEmpty }
        
        if !dates.contains(dateString) {
            dates.append(dateString)
            let newDatesString = dates.joined(separator: ",")
            DispatchQueue.main.async { [weak self] in
                self?.checkInDatesString = newDatesString
            }
            return true
        }
        return false
    }
    
    // Get all check-in dates
    func getCheckInDates() -> Set<String> {
        streakQueue.sync {
            let dates = checkInDatesString.components(separatedBy: ",").filter { !$0.isEmpty }
            return Set(dates)
        }
    }
}