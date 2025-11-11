//
//  CannabisUseFrequency.swift
//  Offleaf
//

import Foundation

enum CannabisUseFrequency: String, CaseIterable, Codable {
    case oneToTwoPerWeek
    case threeToFourPerWeek
    case fiveToSixPerWeek
    case dailyOnceOrTwice
    case dailyMultiple
    case unknown

    init(storedValue: String) {
        if let match = CannabisUseFrequency(rawValue: storedValue) {
            self = match
            return
        }

        switch storedValue.lowercased() {
        case "1-2 times per week", "weekly", "monthly":
            self = .oneToTwoPerWeek
        case "3-4 times per week", "few times a week":
            self = .threeToFourPerWeek
        case "almost every day (5-6 times per week)", "5-6 times per week":
            self = .fiveToSixPerWeek
        case "every day, once or twice", "daily":
            self = .dailyOnceOrTwice
        case "every day, multiple times", "multiple times a day":
            self = .dailyMultiple
        default:
            self = .unknown
        }
    }

    static var assessmentOptions: [CannabisUseFrequency] {
        [.oneToTwoPerWeek, .threeToFourPerWeek, .fiveToSixPerWeek, .dailyOnceOrTwice, .dailyMultiple]
    }

    var assessmentLabel: String {
        switch self {
        case .oneToTwoPerWeek:
            return "1-2 times per week"
        case .threeToFourPerWeek:
            return "3-4 times per week"
        case .fiveToSixPerWeek:
            return "Almost every day (5-6 times per week)"
        case .dailyOnceOrTwice:
            return "Every day, once or twice"
        case .dailyMultiple:
            return "Every day, multiple times"
        case .unknown:
            return "Not set"
        }
    }

    var summaryLabel: String {
        switch self {
        case .unknown:
            return "Not set"
        default:
            return assessmentLabel
        }
    }

    var shortLabel: String {
        switch self {
        case .oneToTwoPerWeek:
            return "1-2x per week"
        case .threeToFourPerWeek:
            return "3-4x per week"
        case .fiveToSixPerWeek:
            return "5-6x per week"
        case .dailyOnceOrTwice:
            return "Daily (1-2x)"
        case .dailyMultiple:
            return "Daily (3+ x)"
        case .unknown:
            return "Not set"
        }
    }

    var estimatedHoursPerDay: Double {
        switch self {
        case .oneToTwoPerWeek:
            return 0.3
        case .threeToFourPerWeek:
            return 0.6
        case .fiveToSixPerWeek:
            return 1.5
        case .dailyOnceOrTwice:
            return 2.5
        case .dailyMultiple:
            return 4.0
        case .unknown:
            return 2.0
        }
    }

    var estimatedSessionsPerDay: Double {
        switch self {
        case .oneToTwoPerWeek:
            return 0.25
        case .threeToFourPerWeek:
            return 0.5
        case .fiveToSixPerWeek:
            return 0.8
        case .dailyOnceOrTwice:
            return 1.5
        case .dailyMultiple:
            return 3.0
        case .unknown:
            return 1.0
        }
    }
}
