//
//  AssessmentResponseTypes.swift
//  Offleaf
//

import Foundation

enum CannabisUseReason: String, CaseIterable, Codable {
    case relax
    case social
    case focus
    case sleep
    case habit
    case other

    init(storedValue: String) {
        if let value = CannabisUseReason(rawValue: storedValue) {
            self = value
            return
        }

        switch storedValue.lowercased() {
        case "relax or relieve stress":
            self = .relax
        case "social or recreational enjoyment":
            self = .social
        case "enhance focus or creativity":
            self = .focus
        case "help with sleep":
            self = .sleep
        case "out of habit or routine":
            self = .habit
        case "other":
            self = .other
        default:
            self = .other
        }
    }

    static var selectionOptions: [CannabisUseReason] {
        [.relax, .social, .focus, .sleep, .habit, .other]
    }

    var displayName: String {
        switch self {
        case .relax:
            return "Relax or relieve stress"
        case .social:
            return "Social or recreational enjoyment"
        case .focus:
            return "Enhance focus or creativity"
        case .sleep:
            return "Help with sleep"
        case .habit:
            return "Out of habit or routine"
        case .other:
            return "Other"
        }
    }
}

enum AssessmentBinaryResponse: String, Codable {
    case yes
    case no
    case unanswered

    init(storedValue: String) {
        switch storedValue.lowercased() {
        case "yes":
            self = .yes
        case "no":
            self = .no
        default:
            self = .unanswered
        }
    }

    var displayText: String {
        switch self {
        case .yes:
            return "Yes"
        case .no:
            return "No"
        case .unanswered:
            return ""
        }
    }
}

enum AssessmentReadinessLevel: String, CaseIterable, Codable {
    case notAtAllReady
    case notReady
    case unsure
    case ready
    case completelyReady

    init(storedValue: String) {
        if let value = AssessmentReadinessLevel(rawValue: storedValue) {
            self = value
            return
        }

        switch storedValue.lowercased() {
        case "not at all ready":
            self = .notAtAllReady
        case "not ready":
            self = .notReady
        case "i don't know", "i dont know":
            self = .unsure
        case "ready":
            self = .ready
        case "completely ready":
            self = .completelyReady
        default:
            self = .unsure
        }
    }

    var displayName: String {
        switch self {
        case .notAtAllReady:
            return "Not at all ready"
        case .notReady:
            return "Not ready"
        case .unsure:
            return "I don't know"
        case .ready:
            return "Ready"
        case .completelyReady:
            return "Completely ready"
        }
    }
}

enum AssessmentConfidenceLevel: String, CaseIterable, Codable {
    case notAtAllConfident
    case notConfident
    case unsure
    case confident
    case veryConfident

    init(storedValue: String) {
        if let value = AssessmentConfidenceLevel(rawValue: storedValue) {
            self = value
            return
        }

        switch storedValue.lowercased() {
        case "not at all confident":
            self = .notAtAllConfident
        case "not confident":
            self = .notConfident
        case "i don't know", "i dont know":
            self = .unsure
        case "confident":
            self = .confident
        case "very confident":
            self = .veryConfident
        default:
            self = .unsure
        }
    }

    var displayName: String {
        switch self {
        case .notAtAllConfident:
            return "Not at all confident"
        case .notConfident:
            return "Not confident"
        case .unsure:
            return "I don't know"
        case .confident:
            return "Confident"
        case .veryConfident:
            return "Very confident"
        }
    }
}

enum AssessmentMotivationArea: String, CaseIterable, Codable {
    case physicalHealth
    case mentalClarity
    case relationships
    case finances
    case selfImage
    case other

    init(storedValue: String) {
        if let value = AssessmentMotivationArea(rawValue: storedValue) {
            self = value
            return
        }

        switch storedValue.lowercased() {
        case "physical health and fitness":
            self = .physicalHealth
        case "mental clarity and focus":
            self = .mentalClarity
        case "relationships and family":
            self = .relationships
        case "finances or saving money":
            self = .finances
        case "self-image":
            self = .selfImage
        case "other":
            self = .other
        default:
            self = .other
        }
    }

    var displayName: String {
        switch self {
        case .physicalHealth:
            return "Physical health and fitness"
        case .mentalClarity:
            return "Mental clarity and focus"
        case .relationships:
            return "Relationships and family"
        case .finances:
            return "Finances or saving money"
        case .selfImage:
            return "Self-image"
        case .other:
            return "Other"
        }
    }
}
