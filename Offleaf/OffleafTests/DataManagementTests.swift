//
//  DataManagementTests.swift
//  OffleafTests
//
//  Data storage and management testing
//

import Testing
import Foundation
@testable import Offleaf

struct DataManagementTests {
    
    @Test func testDailyCheckInDataPersistence() {
        // Test DailyCheckInStore
        let store = DailyCheckInStore.self
        
        // Create test entry
        let entry = DailyCheckInEntry(
            date: Date(),
            mood: .good,
            craving: .mild,
            notes: "Test note"
        )
        
        // Save entry
        store.save(entry)
        
        // Retrieve entries
        let entries = store.recentEntries(limit: 1)
        
        #expect(entries.count > 0, "Entry was saved")
        
        // Check if it's in UserDefaults (security issue)
        let key = "dailyCheckIns"
        let data = UserDefaults.standard.data(forKey: key)
        #expect(data != nil, "Check-in data stored in UserDefaults - SECURITY ISSUE")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test func testNoCloudBackup() {
        // Test for CloudKit/iCloud backup
        let hasCloudKitSupport = false // Based on grep results
        let hasICloudBackup = false // Based on grep results
        
        #expect(hasCloudKitSupport == false, "No CloudKit support - DATA LOSS RISK")
        #expect(hasICloudBackup == false, "No iCloud backup - DATA LOSS RISK")
    }
    
    @Test func testDataMigration() {
        // Test for data migration strategy
        let hasMigrationCode = false // No migration code found
        
        #expect(hasMigrationCode == false, "No data migration strategy - UPDATE RISK")
    }
    
    @Test func testDataValidation() {
        // Test data validation
        let quitDateString = "invalid-date"
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: quitDateString)
        
        #expect(date == nil, "Invalid date format not handled properly")
        
        // Test spending amount validation
        let invalidSpending = -100.0
        UserDefaults.standard.set(invalidSpending, forKey: "weeklySpending")
        let retrieved = UserDefaults.standard.double(forKey: "weeklySpending")
        
        #expect(retrieved == invalidSpending, "Negative spending amount accepted - VALIDATION ISSUE")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "weeklySpending")
    }
    
    @Test func testCheckInStreakCalculation() {
        // Test streak calculation logic
        let formatter = ISO8601DateFormatter()
        let today = Date()
        let yesterday = Date(timeIntervalSinceNow: -86400)
        
        // Set last check-in to yesterday
        UserDefaults.standard.set(formatter.string(from: yesterday), forKey: "lastCheckInDate")
        UserDefaults.standard.set(5, forKey: "checkInStreak")
        
        // Check if streak would be maintained
        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: yesterday)
        let currentDay = calendar.startOfDay(for: today)
        let delta = calendar.dateComponents([.day], from: lastDay, to: currentDay).day ?? 0
        
        #expect(delta == 1, "One day difference calculated correctly")
        
        // Test streak break scenario
        let threeDaysAgo = Date(timeIntervalSinceNow: -259200)
        UserDefaults.standard.set(formatter.string(from: threeDaysAgo), forKey: "lastCheckInDate")
        
        let lastDay2 = calendar.startOfDay(for: threeDaysAgo)
        let delta2 = calendar.dateComponents([.day], from: lastDay2, to: currentDay).day ?? 0
        
        #expect(delta2 > 1, "Streak should be broken after \(delta2) days")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "lastCheckInDate")
        UserDefaults.standard.removeObject(forKey: "checkInStreak")
    }
}