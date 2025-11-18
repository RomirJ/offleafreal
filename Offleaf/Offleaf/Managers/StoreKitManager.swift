//
//  StoreKitManager.swift
//  Offleaf
//
//  Created by Assistant on 10/21/25.
//

import SwiftUI
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionStatuses: [Product.SubscriptionInfo.Status] = []
    
    enum ProductID: String, CaseIterable {
        case monthly = "com.offleaf.premium.monthly"
        case annual = "com.offleaf.premium.annual"
        case lifetime = "com.offleaf.premium.lifetime.unlock"
    }

    private var productIDs: [String] {
        ProductID.allCases.map(\.rawValue)
    }
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            guard let self else { return }
            for await result in StoreKit.Transaction.updates {
                do {
                    try await self.process(transactionResult: result)
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }

    @MainActor
    private func process(transactionResult: VerificationResult<StoreKit.Transaction>) async throws {
        let transaction = try checkVerified(transactionResult)
        await updateCustomerProductStatus()
        await transaction.finish()
    }
    
    @MainActor
    func loadProducts() async {
        do {
            subscriptions = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updateCustomerProductStatus()
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
#if DEBUG
        switch result {
        case .unverified(let value, let error):
            print("Warning: unverified StoreKit result: \(error)")
            return value
        case .verified(let safe):
            return safe
        }
#else
        switch result {
        case .unverified(_, let error):
            print("StoreKit verification failed: \(error)")
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
#endif
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubs: [Product] = []
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    if !purchasedSubs.contains(where: { $0.id == subscription.id }) {
                        purchasedSubs.append(subscription)
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        // Include non-consumable "lifetime" entitlement if purchased
        for product in subscriptions where product.type == .nonConsumable {
            do {
                if let latest = await StoreKit.Transaction.latest(for: product.id) {
                    let transaction = try checkVerified(latest)
                    if transaction.revocationDate == nil && !purchasedSubs.contains(where: { $0.id == product.id }) {
                        purchasedSubs.append(product)
                    }
                }
            } catch {
                print("Failed to verify transaction for \(product.id): \(error)")
            }
        }
        
        var statusByProduct: [String: Product.SubscriptionInfo.Status] = [:]

        for product in subscriptions where product.subscription != nil {
            guard let subscription = product.subscription else { continue }
            do {
                let statusList = try await subscription.status
                for status in statusList {
                    let productID = status.productID.isEmpty ? product.id : status.productID
                    guard !productID.isEmpty else { continue }
                    if let existing = statusByProduct[productID] {
                        if priority(for: status) > priority(for: existing) {
                            statusByProduct[productID] = status
                        }
                    } else {
                        statusByProduct[productID] = status
                    }
                }
            } catch {
                print("Failed to fetch status for \(product.id): \(error)")
            }
        }

        self.purchasedSubscriptions = purchasedSubs
        self.subscriptionStatuses = Array(statusByProduct.values).sorted { lhs, rhs in
            priority(for: lhs) > priority(for: rhs)
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateCustomerProductStatus()
    }
    
    var hasActiveSubscription: Bool {
        let hasActiveStatus = subscriptionStatuses.contains { status in
            switch status.state {
            case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                return true
            default:
                return isTrial(status)
            }
        }
        let ownsLifetime = purchasedSubscriptions.contains { $0.type == .nonConsumable }
        return hasActiveStatus || ownsLifetime
    }
    
    var isInTrialPeriod: Bool {
        subscriptionStatuses.contains { isTrial($0) }
    }
    
    func productPrice(_ product: Product) -> String {
        return product.displayPrice
    }
    
    func productPeriod(_ product: Product) -> String {
        if product.type == .nonConsumable {
            return "one-time"
        }
        
        guard let subscription = product.subscription else { return "" }
        
        let unit = subscription.subscriptionPeriod.unit
        let count = subscription.subscriptionPeriod.value
        
        switch unit {
        case .day:
            return count == 1 ? "day" : "\(count) days"
        case .week:
            return count == 1 ? "week" : "\(count) weeks"
        case .month:
            return count == 1 ? "month" : "\(count) months"
        case .year:
            return count == 1 ? "year" : "\(count) years"
        @unknown default:
            return ""
        }
    }
}

enum StoreError: Error {
    case failedVerification
}

extension StoreKitManager {
    var lifetimeProductID: String? {
        ProductID.lifetime.rawValue
    }
    
    var currentSubscriptionStatus: Product.SubscriptionInfo.Status? {
        subscriptionStatuses.sorted { lhs, rhs in
            priority(for: lhs) > priority(for: rhs)
        }.first
    }
    
    private func priority(for status: Product.SubscriptionInfo.Status) -> Int {
        if isTrial(status) { return 2 }
        switch status.state {
        case .subscribed: return 3
        case .inGracePeriod, .inBillingRetryPeriod: return 1
        default: return 0
        }
    }
    
    func product(withID id: String) -> Product? {
        subscriptions.first { $0.id == id }
    }
    
    func displayName(forProductID id: String) -> String {
        product(withID: id)?.displayName ?? id
    }

    private func isTrial(_ status: Product.SubscriptionInfo.Status) -> Bool {
        status.isTrial
    }
}

extension Product.SubscriptionInfo.Status {
    var productID: String {
        let renewalProductID: String? = {
            switch renewalInfo {
            case .verified(let info):
                return info.currentProductID
            case .unverified(let info, _):
                return info.currentProductID
            }
        }()

        if let id = renewalProductID, !id.isEmpty {
            return id
        }

        let transactionProductID: String? = {
            switch transaction {
            case .verified(let transaction):
                return transaction.productID
            case .unverified(let transaction, _):
                return transaction.productID
            }
        }()

        if let id = transactionProductID, !id.isEmpty {
            return id
        }

        return ""
    }

    var expirationDate: Date? {
        let renewalExpiration: Date? = {
            switch renewalInfo {
            case .verified(let info):
                return info.renewalDate
            case .unverified(let info, _):
                return info.renewalDate
            }
        }()

        if let date = renewalExpiration {
            return date
        }

        let transactionExpiration: Date? = {
            switch transaction {
            case .verified(let transaction):
                return transaction.expirationDate
            case .unverified(let transaction, _):
                return transaction.expirationDate
            }
        }()

        return transactionExpiration
    }

    var isTrial: Bool {
        let introductoryOfferApplied: Bool = {
            switch transaction {
            case .verified(let transaction):
                return transaction.offer?.type == .introductory
            case .unverified(let transaction, _):
                return transaction.offer?.type == .introductory
            }
        }()

        return introductoryOfferApplied
    }
}
