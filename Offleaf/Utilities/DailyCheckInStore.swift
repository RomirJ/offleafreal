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
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([DailyCheckInEntry].self, from: data)
        else {
            return []
        }

        return decoded
    }

    static func saveEntries(_ entries: [DailyCheckInEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
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
