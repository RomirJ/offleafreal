//
//  SubscriptionManager.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var subscriptionType = ""
    @Published private(set) var trialEndDate: Date?
    
    private let storeKitManager = StoreKitManager.shared
    
    private init() {
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    var isInTrialPeriod: Bool {
        storeKitManager.isInTrialPeriod
    }
    
    var remainingTrialDays: Int {
        guard isInTrialPeriod, let endDate = trialEndDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
    
    var hasTrialExpired: Bool {
        guard let endDate = trialEndDate else { return false }
        return Date() >= endDate && !storeKitManager.hasActiveSubscription
    }
    
    @MainActor
    func checkSubscriptionStatus() async {
        await storeKitManager.updateCustomerProductStatus()

        hasActiveSubscription = storeKitManager.hasActiveSubscription
        var updatedTrialEndDate = trialEndDate
        subscriptionType = ""

        if let status = storeKitManager.currentSubscriptionStatus {
            let productID = status.productID
            subscriptionType = storeKitManager.displayName(forProductID: productID)

            if status.isTrial || status.state == .inGracePeriod || status.state == .inBillingRetryPeriod {
                updatedTrialEndDate = status.expirationDate ?? updatedTrialEndDate
            } else if status.state == .subscribed {
                updatedTrialEndDate = status.expirationDate ?? updatedTrialEndDate
            }
        }

        if subscriptionType.isEmpty && hasActiveSubscription,
           let product = storeKitManager.purchasedSubscriptions.first {
            subscriptionType = product.displayName
        }

        if let lifetimeProductID = storeKitManager.lifetimeProductID,
           let lifetimeResult = await StoreKit.Transaction.latest(for: lifetimeProductID) {
            if case .verified(let lifetimeTransaction) = lifetimeResult,
               lifetimeTransaction.revocationDate == nil {
                subscriptionType = storeKitManager.displayName(forProductID: lifetimeProductID)
                updatedTrialEndDate = nil
            }
        }

        if subscriptionType.isEmpty && hasActiveSubscription {
            subscriptionType = "Premium Access"
        }

        trialEndDate = updatedTrialEndDate
    }
    
    func purchaseSubscription(product: Product) async throws -> Bool {
        do {
            let transaction = try await storeKitManager.purchase(product)
            if transaction != nil {
                await checkSubscriptionStatus()
                return true
            }
            return false
        } catch {
            print("[Subscription] ERROR: Purchase failed for product \(product.displayName): \(error.localizedDescription)")
            
            // Track critical payment failures
            #if !DEBUG
            // Analytics.track("purchase_failed", properties: [
            //     "product_id": product.id,
            //     "error": error.localizedDescription
            // ])
            #endif
            
            throw error
        }
    }
    
    func restorePurchases() async throws {
        try await storeKitManager.restorePurchases()
        await checkSubscriptionStatus()
    }
    
    func getSubscriptionStatus() -> String {
        if hasActiveSubscription {
            return subscriptionType
        } else if isInTrialPeriod {
            return "Free Trial - \(remainingTrialDays) days left"
        } else if hasTrialExpired {
            return "Trial Expired"
        } else {
            return "No Subscription"
        }
    }
    
    func resetSubscription() {
        Task {
            await checkSubscriptionStatus()
        }
    }
}
