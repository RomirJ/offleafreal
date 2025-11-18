//
//  EntitlementManager.swift
//  Offleaf
//
//  Created by Assistant on 10/21/25.
//

import SwiftUI
import StoreKit

@MainActor
class EntitlementManager: ObservableObject {
    static let shared = EntitlementManager()
    
    @Published private(set) var hasPremiumAccess = false
    @Published private(set) var accessLevel: AccessLevel = .free
    
    private let storeKitManager = StoreKitManager.shared
    
    enum AccessLevel {
        case free
        case trial
        case premium
    }
    
    enum Feature: String {
        case unlimitedJournalEntries
        case advancedStatistics
        case customReminders
        case exportData
        case emergencyContacts
        case breathingExercises
        case walkTracking
        case triggerPlanning
        case allContent
    }
    
    private init() {
        Task {
            await verifyEntitlements()
        }
    }
    
    func verifyEntitlements() async {
        await storeKitManager.updateCustomerProductStatus()
        
        let hasActiveSubscription = storeKitManager.hasActiveSubscription
        let isInTrial = storeKitManager.isInTrialPeriod
        
        if hasActiveSubscription {
            accessLevel = .premium
            hasPremiumAccess = true
        } else if isInTrial {
            accessLevel = .trial
            hasPremiumAccess = true
        } else {
            accessLevel = .free
            hasPremiumAccess = false
        }
        
        if !hasPremiumAccess {
            let ownsPremium = storeKitManager.purchasedSubscriptions.contains { $0.id.contains("premium") }
            if ownsPremium {
                accessLevel = .premium
                hasPremiumAccess = true
            }
        }
    }
    
    func hasAccess(to feature: Feature) -> Bool {
        switch accessLevel {
        case .free:
            return freeFeatures.contains(feature)
        case .trial, .premium:
            return true
        }
    }
    
    private var freeFeatures: Set<Feature> {
        return [
            .breathingExercises,
            .walkTracking
        ]
    }
    
    func requiresPremium(for feature: Feature) -> Bool {
        return !freeFeatures.contains(feature)
    }
    
    func verifyPremiumAccess() async -> Bool {
        await verifyEntitlements()
        return hasPremiumAccess
    }
    
    func refreshEntitlements() {
        Task {
            await verifyEntitlements()
        }
    }
}
