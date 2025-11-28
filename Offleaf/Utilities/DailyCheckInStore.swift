//
//  DailyCheckInStore.swift
//  Offleaf
//

import Foundation

enum DailyMoodLevel: String, CaseIterable, Codable {
    case struggling
    case low
    case okay
    case good
    case great

    var emoji: String {
        switch self {
        case .struggling: return "😣"
        case .low: return "😔"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }

    var description: String {
        switch self {
        case .struggling: return "Struggling"
        case .low: return "Low"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var score: Int {
        switch self {
        case .struggling: return 1
        case .low: return 2
        case .okay: return 3
        case .good: return 4
        case .great: return 5
        }
    }
}

enum CravingIntensity: String, CaseIterable, Codable {
    case none
    case mild
    case moderate
    case strong
    case intense

    var label: String {
        switch self {
        case .none: return "None"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .strong: return "Strong"
        case .intense: return "Intense"
        }
    }

    var score: Int {
        switch self {
        case .none: return 0
        case .mild: return 1
        case .moderate: return 2
        case .strong: return 3
        case .intense: return 4
        }
    }
}

struct DailyCheckInEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: DailyMoodLevel
    let craving: CravingIntensity
    let triggers: [String]
    let practicedCoping: Bool

    init(date: Date, mood: DailyMoodLevel, craving: CravingIntensity, triggers: [String], practicedCoping: Bool) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.craving = craving
        self.triggers = triggers
        self.practicedCoping = practicedCoping
    }
}

enum DailyCheckInStore {
    private static let storageKey = "dailyCheckInEntries"
    private static let maxEntries = 60

    static func loadEntries() -> [DailyCheckInEntry] {
        // Use secure storage for sensitive health data
        if let entries = SecureHealthDataStore.shared.loadSecureData([DailyCheckInEntry].self, for: storageKey) {
            return entries
        }
        
        // Fallback: migrate from UserDefaults if exists
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let decoded = try JSONDecoder().decode([DailyCheckInEntry].self, from: data)
            
            // Migrate to secure storage
            if SecureHealthDataStore.shared.saveSecureData(decoded, for: storageKey) {
                // Only remove from UserDefaults after successful migration
                UserDefaults.standard.removeObject(forKey: storageKey)
                print("[DailyCheckIn] Successfully migrated \(decoded.count) entries to secure storage")
            } else {
                print("[DailyCheckIn] WARNING: Failed to migrate to secure storage, keeping in UserDefaults")
            }
            
            return decoded
        } catch {
            print("[DailyCheckIn] ERROR: Failed to decode check-in entries: \(error)")
            
            // Try to recover from backup
            if let backupData = UserDefaults.standard.data(forKey: "\(storageKey)_backup"),
               let backupEntries = try? JSONDecoder().decode([DailyCheckInEntry].self, from: backupData) {
                print("[DailyCheckIn] Recovered \(backupEntries.count) entries from backup")
                return backupEntries
            }
            
            // Save corrupted data for debugging
            UserDefaults.standard.set(data, forKey: "\(storageKey)_corrupted")
            return []
        }
    }

    static func saveEntries(_ entries: [DailyCheckInEntry]) {
        // Create backup before saving
        if let existingEntries = SecureHealthDataStore.shared.loadSecureData([DailyCheckInEntry].self, for: storageKey) {
            _ = SecureHealthDataStore.shared.saveSecureData(existingEntries, for: "\(storageKey)_backup")
        }
        
        // Save to secure keychain storage instead of UserDefaults
        if !SecureHealthDataStore.shared.saveSecureData(entries, for: storageKey) {
            print("[DailyCheckIn] CRITICAL: Failed to save \(entries.count) check-in entries to secure storage")
            // Try to save to UserDefaults as fallback
            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: "\(storageKey)_fallback")
                print("[DailyCheckIn] Saved to fallback storage")
            }
        }
    }

    static func append(_ entry: DailyCheckInEntry) {
        var entries = loadEntries()
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }
        entries.append(entry)
        entries.sort { $0.date < $1.date }
        if entries.count > maxEntries {
            entries = Array(entries.suffix(maxEntries))
        }
        saveEntries(entries)
    }

    static func recentEntries(limit: Int) -> [DailyCheckInEntry] {
        let entries = loadEntries().sorted { $0.date < $1.date }
        return Array(entries.suffix(limit))
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

extension Notification.Name {
    static let dailyCheckInCompleted = Notification.Name("DailyCheckInCompleted")
}
