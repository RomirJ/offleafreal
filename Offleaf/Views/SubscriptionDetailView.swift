//
//  SubscriptionDetailView.swift
//  Offleaf
//

import SwiftUI
import StoreKit
import Foundation

struct SubscriptionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var storeKitManager = StoreKitManager.shared
    @State private var selectedPlan = "monthly"
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Subscription")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: restorePurchases) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.7, blue: 0.4)))
                        } else {
                            Text("Restore")
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.4))
                        }
                    }
                    .disabled(isProcessing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Status
                        VStack(spacing: 12) {
                            let currentStatus = subscriptionManager.getSubscriptionStatus()
                            let hasPremium = currentStatus.contains("Premium")
                            
                            Image(systemName: subscriptionManager.isInTrialPeriod || hasPremium ? "checkmark.seal.fill" : "clock.fill")
                                .font(.system(size: 40))
                                .foregroundColor(hasPremium ? Color(red: 0.3, green: 0.7, blue: 0.4) : Color(red: 0.9, green: 0.7, blue: 0.3))
                            
                            Text(currentStatus)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if subscriptionManager.isInTrialPeriod {
                                Text("\(subscriptionManager.remainingTrialDays) days remaining")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            } else if subscriptionManager.hasTrialExpired {
                                Text("Trial expired")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            } else if let activeProduct = activeProduct {
                                let billing = billingDescription(for: activeProduct)
                                Text("Billed at \(activeProduct.displayPrice) \(billing.phrase)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Premium Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            Text("OFFLEAF PREMIUM")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            VStack(spacing: 12) {
                                SubscriptionBenefitRow(icon: "infinity", text: "Unlimited journal entries", color: Color(red: 0.4, green: 0.6, blue: 1))
                                SubscriptionBenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced progress analytics", color: Color(red: 0.3, green: 0.7, blue: 0.4))
                                SubscriptionBenefitRow(icon: "person.3.fill", text: "Community support access", color: Color(red: 0.9, green: 0.7, blue: 0.3))
                                SubscriptionBenefitRow(icon: "sparkles", text: "Custom quit plans", color: Color(red: 0.9, green: 0.3, blue: 0.3))
                                SubscriptionBenefitRow(icon: "moon.fill", text: "Sleep tracking integration", color: Color(red: 0.6, green: 0.4, blue: 0.9))
                                SubscriptionBenefitRow(icon: "bell.badge.fill", text: "Smart craving predictions", color: Color(red: 0.3, green: 0.8, blue: 0.8))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        let statusForPlans = subscriptionManager.getSubscriptionStatus()
                        if !statusForPlans.contains("Premium") {
                            // Subscription Plans
                            VStack(spacing: 12) {
                                SubscriptionPlanCard(
                                    title: "Monthly",
                                    price: monthlyPricing.price,
                                    period: monthlyPricing.period,
                                    savings: nil,
                                    isSelected: selectedPlan == "monthly",
                                    action: { selectedPlan = "monthly" }
                                )
                                
                                SubscriptionPlanCard(
                                    title: "Annual",
                                    price: annualPricing.price,
                                    period: annualPricing.period,
                                    savings: annualSavingsLabel,
                                    isSelected: selectedPlan == "annual",
                                    action: { selectedPlan = "annual" }
                                )
                            }
                            
                            // Subscribe Button
                            Button(action: subscribe) {
                                Group {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Text(primaryCTA)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.25, green: 0.6, blue: 0.35)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .padding(.top, 8)
                            .disabled(isProcessing)
                            
                            // Terms
                            Text(trialFootnote)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                        
                        let statusForManage = subscriptionManager.getSubscriptionStatus()
                        if statusForManage.contains("Premium") {
                            // Manage Subscription
                            VStack(spacing: 16) {
                                Button(action: manageSubscription) {
                                    HStack {
                                        Text("Manage Subscription")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                                
                                Button(action: cancelSubscription) {
                                    Text("Cancel Subscription")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                .padding(.top, 8)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .task {
            await storeKitManager.loadProducts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var currentSelectedProduct: Product? {
        switch selectedPlan {
        case "annual":
            return annualProduct
        case "monthly":
            return monthlyProduct
        case "lifetime":
            return storeKitManager.product(withID: StoreKitManager.ProductID.lifetime.rawValue)
        default:
            return nil
        }
    }

    private func subscribe() {
        guard !isProcessing else { return }
        guard let product = currentSelectedProduct else {
            errorMessage = "Unable to load subscription products. Please try again later."
            showError = true
            return
        }

        isProcessing = true
        Task {
            do {
                let success = try await subscriptionManager.purchaseSubscription(product: product)
                await MainActor.run {
                    isProcessing = false
                    if success {
                        dismiss()
                    } else {
                        errorMessage = "Purchase was cancelled"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Purchase failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func restorePurchases() {
        guard !isProcessing else { return }
        isProcessing = true
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                await MainActor.run {
                    isProcessing = false
                    if subscriptionManager.hasActiveSubscription {
                        dismiss()
                    } else {
                        errorMessage = "No purchases to restore"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Restore failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func manageSubscription() {
        openSubscriptionsPage()
    }
    
    private func cancelSubscription() {
        openSubscriptionsPage()
    }

    private func openSubscriptionsPage() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        openURL(url)
    }

    private var monthlyProduct: Product? {
        storeKitManager.product(withID: StoreKitManager.ProductID.monthly.rawValue)
    }

    private var annualProduct: Product? {
        storeKitManager.product(withID: StoreKitManager.ProductID.annual.rawValue)
    }

    private var activeProduct: Product? {
        let status = subscriptionManager.getSubscriptionStatus().lowercased()
        if status.contains("annual") {
            return annualProduct
        }
        if status.contains("month") {
            return monthlyProduct
        }
        return nil
    }

    private var monthlyPricing: (price: String, period: String) {
        pricing(for: monthlyProduct, fallbackPrice: "$14.99", fallbackPeriod: "/ month")
    }

    private var annualPricing: (price: String, period: String) {
        pricing(for: annualProduct, fallbackPrice: "$69.99", fallbackPeriod: "/ year")
    }

    private var trialFootnote: String {
        let product = selectedPlan == "annual" ? annualProduct : monthlyProduct
        guard let product else {
            return selectedPlan == "annual"
                ? "Includes a 3-day free trial, then $69.99/year. Cancel anytime."
                : "Includes a 3-day free trial, then $14.99/month. Cancel anytime."
        }

        if let offer = product.subscription?.introductoryOffer {
            let periodDescription = formatted(period: offer.period)
            let billing = billingDescription(for: product)
            return "Includes a \(periodDescription) free trial, then \(product.displayPrice) \(billing.phrase). Cancel anytime."
        }

        let billing = billingDescription(for: product)
        return "You'll be charged \(product.displayPrice) \(billing.phrase). Cancel anytime."
    }

    private var primaryCTA: String {
        let product = selectedPlan == "annual" ? annualProduct : monthlyProduct
        if let offer = product?.subscription?.introductoryOffer {
            let periodDescription = formatted(period: offer.period).capitalized
            return "Start \(periodDescription) Free Trial"
        }
        if let product {
            return "Continue for \(product.displayPrice)"
        }
        return "Start Free Trial"
    }

    private func pricing(for product: Product?, fallbackPrice: String, fallbackPeriod: String) -> (String, String) {
        guard let product else {
            return (fallbackPrice, fallbackPeriod)
        }
        let period = storeKitManager.productPeriod(product)
        let periodText = period.isEmpty ? "" : "/ \(period)"
        return (product.displayPrice, periodText)
    }

    private var annualSavingsLabel: String? {
        var monthlyPrice: Double?
        var annualPrice: Double?

        if let monthlyProduct,
           let monthlySubscription = monthlyProduct.subscription,
           monthlySubscription.subscriptionPeriod.unit == .month,
           monthlySubscription.subscriptionPeriod.value == 1 {
            monthlyPrice = NSDecimalNumber(decimal: monthlyProduct.price).doubleValue
        }

        if let annualProduct,
           let annualSubscription = annualProduct.subscription,
           annualSubscription.subscriptionPeriod.unit == .year {
            annualPrice = NSDecimalNumber(decimal: annualProduct.price).doubleValue
        }

        if monthlyPrice == nil { monthlyPrice = 14.99 }
        if annualPrice == nil { annualPrice = 69.99 }

        guard let monthlyPrice, let annualPrice, monthlyPrice > 0 else { return nil }

        let yearlyMonthlyCost = monthlyPrice * 12.0
        guard yearlyMonthlyCost > 0 else { return nil }

        let savingsRatio = (yearlyMonthlyCost - annualPrice) / yearlyMonthlyCost
        let percentage = Int(round(savingsRatio * 100))

        guard percentage > 0 else { return nil }
        return "Save \(percentage)%"
    }

    private func billingDescription(for product: Product) -> (unit: String, phrase: String) {
        guard let subscription = product.subscription else {
            return ("purchase", "one-time")
        }

        switch subscription.subscriptionPeriod.unit {
        case .day:
            return ("day", "per day")
        case .week:
            return ("week", "per week")
        case .month:
            return ("month", "per month")
        case .year:
            return ("year", "per year")
        @unknown default:
            return ("period", "per period")
        }
    }

    private func formatted(period: Product.SubscriptionPeriod) -> String {
        let singular: String
        switch period.unit {
        case .day: singular = "day"
        case .week: singular = "week"
        case .month: singular = "month"
        case .year: singular = "year"
        @unknown default: singular = "period"
        }
        if period.value == 1 {
            return "1 \(singular)"
        }
        return "\(period.value)-\(singular)"
    }
}

struct SubscriptionPlanCard: View {
    let title: String
    let price: String
    let period: String
    let savings: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.9, green: 0.7, blue: 0.3))
                                )
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Text(price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(period)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.4) : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubscriptionBenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct SubscriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionDetailView()
    }
}
