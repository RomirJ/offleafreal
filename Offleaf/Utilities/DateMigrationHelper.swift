//
//  DateMigrationHelper.swift
//  Offleaf
//
//  Handles migration of dates from UTC to local timezone
//

import Foundation
import SwiftUI

class DateMigrationHelper {
    @AppStorage("datesMigrated") private static var datesMigrated = false
    @AppStorage("checkInDates") private static var checkInDatesString = ""
    
    static func migrateIfNeeded() {
        // Only migrate once
        guard !datesMigrated else { return }
        
        // Get existing dates
        let existingDates = checkInDatesString.components(separatedBy: ",").filter { !$0.isEmpty }
        guard !existingDates.isEmpty else {
            // No dates to migrate
            datesMigrated = true
            return
        }
        
        // Create formatters for both timezones
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyy-MM-dd"
        localFormatter.timeZone = TimeZone.current
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Migrate each date
        var migratedDates: [String] = []
        for dateString in existingDates {
            if let date = utcFormatter.date(from: dateString) {
                // Convert UTC date to local date string
                let localDateString = localFormatter.string(from: date)
                if !migratedDates.contains(localDateString) {
                    migratedDates.append(localDateString)
                }
            } else {
                // If parsing fails, keep the original (might already be local)
                if !migratedDates.contains(dateString) {
                    migratedDates.append(dateString)
                }
            }
        }
        
        // Save migrated dates
        checkInDatesString = migratedDates.joined(separator: ",")
        datesMigrated = true
        
        print("Migrated \(existingDates.count) dates from UTC to local timezone")
    }
    
    // Reset migration flag (useful for testing)
    static func resetMigration() {
        datesMigrated = false
    }
}