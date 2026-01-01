//
//  PricingView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI
import StoreKit
import Foundation

struct PricingView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var storeKitManager = StoreKitManager.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var selectedProduct: Product?
    @State private var selectedFallbackPlan: SubscriptionPlanOption?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isNetworkError = false
    @State private var showPromoOffer = true
    @State private var promoPurchasing = false
    @State private var showSpinWheel = false
    @State private var returnToPromoOffer = false
    
    private static let termsOfUseURL: URL = {
        URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") 
        ?? URL(string: "https://www.apple.com/legal/")!
    }()
    
    private static let privacyPolicyURL: URL = {
        URL(string: "https://offleaf-legal-hub.lovable.app/")
        ?? URL(string: "https://lovable.app/privacy")!
    }()
    
    var onComplete: () -> Void
    
    var body: some View {
        if showSpinWheel {
            SpinWheelView(
                onContinue: {
                    // Go back to promo offer after spin
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSpinWheel = false
                        showPromoOffer = true
                    }
                },
                onDismiss: {
                    // User dismissed from special offer X button - go back to promo offer
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSpinWheel = false
                        showPromoOffer = true
                        returnToPromoOffer = true
                    }
                }
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        } else if showPromoOffer {
            PromoOfferView(
                isPurchasing: $promoPurchasing,
                onPurchase: { planType in
                    Task {
                        await purchasePromoSubscription(planType: planType)
                    }
                },
                onRestore: {
                    Task {
                        await restorePurchases()
                    }
                }
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
        } else {
            GeometryReader { geometry in
                let topInset = geometry.safeAreaInsets.top
                let bottomInset = geometry.safeAreaInsets.bottom

                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    let bottomPadding = max(bottomInset, 20) + 32

                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Image("LeafLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .padding(.top, max(topInset - 20, 0))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your personalized")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("plan is ready")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Unlock full access to continue your journey.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                        if storeKitManager.subscriptions.isEmpty {
                            fallbackPlansSection
                        } else {
                            liveProductsSection
                        }

                        VStack(spacing: 12) {
                            Text(selectedFootnote)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Button(action: {
                                if !networkMonitor.isConnected {
                                    errorMessage = "No internet connection. Please check your connection and try again."
                                    showError = true
                                } else {
                                    Task {
                                        await purchaseSubscription()
                                    }
                                }
                            }) {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color.white)
                                        .cornerRadius(28)
                                } else if !networkMonitor.isConnected {
                                    HStack {
                                        Image(systemName: "wifi.slash")
                                            .font(.system(size: 16))
                                        Text("No Connection")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(28)
                                } else {
                                    Text("Start Free Trial")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color.white)
                                        .cornerRadius(28)
                                }
                            }
                            .padding(.horizontal, 24)
                            .disabled((selectedProduct == nil && selectedFallbackPlan == nil) || isPurchasing || !networkMonitor.isConnected)

                            if storeKitManager.subscriptions.isEmpty {
                                Text("Sign in to your App Store account to complete the purchase when you're ready.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                Task {
                                    await restorePurchases()
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 16) {
                                Link("Terms of Use", destination: Self.termsOfUseURL)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Link("Privacy Policy", destination: Self.privacyPolicyURL)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear
                        .frame(height: bottomPadding)
                }
                }
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.4)))
            .alert("Error", isPresented: $showError) {
            if isNetworkError {
                Button("Try Again") {
                    Task {
                        await purchaseSubscription()
                    }
                }
                Button("Cancel", role: .cancel) {
                    isNetworkError = false
                }
            } else {
                Button("OK", role: .cancel) {}
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let firstProduct = storeKitManager.subscriptions.first {
                selectedProduct = firstProduct
            } else if selectedFallbackPlan == nil {
                selectedFallbackPlan = fallbackPlans.first
            }
        }
        .onChange(of: storeKitManager.subscriptions) { oldValue, newValue in
            if let firstProduct = newValue.first {
                selectedProduct = firstProduct
                selectedFallbackPlan = nil
            }
        }
        }
    }
    
    private var selectedFootnote: String {
        if let product = selectedProduct {
            if let subscription = product.subscription {
                let unit = subscription.subscriptionPeriod.unit
                let isAnnual = unit == .year || product.id.contains("annual")
                return "3-day free trial, then \(product.displayPrice)/\(isAnnual ? "year" : "month")"
            } else {
                return "Pay a one-time \(product.displayPrice) for lifetime access."
            }
        } else if let fallback = selectedFallbackPlan {
            return fallback.footnote
        } else {
            return "3-day free trial, then $14.99/month."
        }
    }

    @ViewBuilder
    private var fallbackPlansSection: some View {
        VStack(spacing: 14) {
            ForEach(fallbackPlans) { plan in
                StaticSubscriptionCard(
                    plan: plan,
                    isSelected: selectedFallbackPlan?.id == plan.id
                ) {
                    selectedFallbackPlan = plan
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
        .onAppear {
            if selectedFallbackPlan == nil {
                selectedFallbackPlan = fallbackPlans.first
            }
        }
    }

    @ViewBuilder
    private var liveProductsSection: some View {
        VStack(spacing: 20) {
            ForEach(storeKitManager.subscriptions.sorted(by: { $0.price < $1.price }), id: \.id) { product in
                SubscriptionCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    storeKitManager: storeKitManager
                ) {
                    selectedProduct = product
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    @MainActor
    private func purchasePromoSubscription(planType: String) async {
        // First, fetch the correct product based on plan type
        await storeKitManager.loadProducts()
        
        // Use the promotional product IDs with the new pricing
        let productID = planType == "yearly" ? 
            StoreKitManager.ProductID.promoAnnual.rawValue : 
            StoreKitManager.ProductID.promoMonthly.rawValue
        
        guard let product = storeKitManager.product(withID: productID) else {
            errorMessage = "Product not available. Please try again."
            showError = true
            withAnimation(.easeInOut(duration: 0.4)) {
                showPromoOffer = false  // Dismiss the promo view to show error
            }
            return
        }
        
        promoPurchasing = true
        isNetworkError = false
        
        do {
            let success = try await subscriptionManager.purchaseSubscription(product: product)
            if success {
                onComplete()  // This takes the user into the main app
            } else {
                // Purchase was cancelled or pending - show spin wheel
                print("[Purchase] Transaction returned nil - user likely cancelled")
                promoPurchasing = false
                withAnimation(.easeInOut(duration: 0.4)) {
                    showPromoOffer = false
                    showSpinWheel = true
                }
                return
            }
        } catch StoreError.failedVerification {
            errorMessage = "Purchase verification failed. Please try again."
            showError = true
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            // Network-specific errors
            isNetworkError = true
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                errorMessage = "No internet connection. Please check your connection and try again."
            case NSURLErrorTimedOut:
                errorMessage = "Request timed out. Please try again."
            case NSURLErrorNetworkConnectionLost:
                errorMessage = "Connection lost. Please try again."
            default:
                errorMessage = "Network error. Please check your connection and try again."
            }
            showError = true
        } catch {
            let nsError = error as NSError
            print("[Purchase] Error: domain=\(nsError.domain), code=\(nsError.code), description=\(error.localizedDescription)")
            
            // Check if user cancelled (StoreKit error code 2 or specific message)
            if nsError.domain == "SKErrorDomain" && nsError.code == 2 {
                // User cancelled - show spin wheel
                print("[Purchase] User cancelled - showing spin wheel")
                errorMessage = ""
                showError = false
                withAnimation(.easeInOut(duration: 0.4)) {
                    showPromoOffer = false
                    showSpinWheel = true
                }
            } else if error.localizedDescription.lowercased().contains("cancelled") || 
                      error.localizedDescription.lowercased().contains("canceled") {
                // Alternative check for cancellation
                print("[Purchase] User cancelled (alt check) - showing spin wheel")
                errorMessage = ""
                showError = false
                withAnimation(.easeInOut(duration: 0.4)) {
                    showPromoOffer = false
                    showSpinWheel = true
                }
            } else {
                // Other errors
                errorMessage = "Purchase failed: \(error.localizedDescription)"
                showError = true
                withAnimation(.easeInOut(duration: 0.4)) {
                    showPromoOffer = false  // Dismiss promo view to show error
                }
            }
        }
        
        promoPurchasing = false
    }
    
    @MainActor
    private func purchaseSubscription() async {
        guard let product = selectedProduct else {
            onComplete()
            return
        }

        isPurchasing = true
        isNetworkError = false
        
        do {
            let success = try await subscriptionManager.purchaseSubscription(product: product)
            if success {
                onComplete()
            }
        } catch StoreError.failedVerification {
            errorMessage = "Purchase verification failed. Please try again."
            showError = true
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            // Network-specific errors
            isNetworkError = true
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                errorMessage = "No internet connection. Please check your connection and try again."
            case NSURLErrorTimedOut:
                errorMessage = "Request timed out. Please try again."
            case NSURLErrorNetworkConnectionLost:
                errorMessage = "Connection lost. Please try again."
            default:
                errorMessage = "Network error. Please check your connection and try again."
            }
            showError = true
        } catch {
            // Check if user cancelled
            if (error as NSError).domain == "SKErrorDomain" && (error as NSError).code == 2 {
                // User cancelled (SKError.paymentCancelled) - don't show error
                errorMessage = ""
                showError = false
            } else {
                // Other errors
                errorMessage = "Purchase failed: \(error.localizedDescription)"
                showError = true
            }
        }
        
        isPurchasing = false
    }
    
    @MainActor
    private func restorePurchases() async {
        isPurchasing = true
        
        do {
            try await subscriptionManager.restorePurchases()
            if subscriptionManager.hasActiveSubscription {
                onComplete()
            } else {
                errorMessage = "No purchases to restore"
                showError = true
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            showError = true
        }
        
        isPurchasing = false
    }
}

struct SubscriptionCard: View {
    let product: Product
    let isSelected: Bool
    let storeKitManager: StoreKitManager
    let onTap: () -> Void
    
    private enum PlanKind {
        case monthly
        case annual
        case lifetime
        case other
    }
    
    private var planKind: PlanKind {
        if product.id.contains("annual") { return .annual }
        if product.id.contains("lifetime") { return .lifetime }
        if product.id.contains("monthly") { return .monthly }
        return .other
    }
    
    private var title: String {
        switch planKind {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        case .lifetime:
            return "Lifetime"
        case .other:
            return product.displayName
        }
    }
    
    private var priceSuffix: String {
        switch planKind {
        case .lifetime:
            return "one-time"
        default:
            let period = storeKitManager.productPeriod(product)
            return period.isEmpty ? "" : "/ \(period)"
        }
    }
    
    private var detailText: String {
        switch planKind {
        case .monthly:
            return "Flexible access. Cancel anytime."
        case .annual:
            return "\(annualSavingsCopy). Includes 3-day free trial."
        case .lifetime:
            return "Pay once, own OffLeaf for life."
        case .other:
            return ""
        }
    }
    
    private var tagText: String? {
        planKind == .annual ? "Best Value" : nil
    }

    private var annualSavingsCopy: String {
        guard planKind == .annual else { return "Save more." }

        if let monthlyProduct = storeKitManager.product(withID: StoreKitManager.ProductID.monthly.rawValue),
           let monthlySubscription = monthlyProduct.subscription,
           monthlySubscription.subscriptionPeriod.unit == .month,
           monthlySubscription.subscriptionPeriod.value == 1 {
            let monthlyPrice = NSDecimalNumber(decimal: monthlyProduct.price).doubleValue
            let annualPrice = NSDecimalNumber(decimal: product.price).doubleValue

            if monthlyPrice > 0 {
                let yearlyMonthlyCost = monthlyPrice * 12.0
                if yearlyMonthlyCost > 0 {
                    let percentage = Int(round(((yearlyMonthlyCost - annualPrice) / yearlyMonthlyCost) * 100))
                    if percentage > 0 {
                        return "Save \(percentage)%"
                    }
                }
            }
        }

        return "Save 61%"
    }

    private var includesTrial: Bool {
        planKind != .lifetime && product.subscription != nil
    }
    
    private var monthlyEquivalentPrice: String {
        let annualPrice = NSDecimalNumber(decimal: product.price).doubleValue
        let monthlyEquivalent = annualPrice / 12.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode
        return formatter.string(from: NSNumber(value: monthlyEquivalent)) ?? "$5.83"
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(primaryTextColor)
                        
                        if let tagText = tagText {
                            Text(tagText)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(tagForegroundColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(tagBackgroundColor)
                                )
                        }
                    }
                    
                    Group {
                        if planKind == .annual {
                            // For annual plan, show monthly breakdown with crossed out comparison
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(monthlyEquivalentPrice)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(primaryTextColor)
                                
                                Text("/ mo")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                Text("$14.99/month")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor.opacity(0.7))
                                    .strikethrough(true, color: secondaryTextColor.opacity(0.5))
                                    .padding(.leading, 4)
                            }
                        } else {
                            // For other plans, show regular price
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(product.displayPrice)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(primaryTextColor)
                                
                                if !priceSuffix.isEmpty {
                                    Text(priceSuffix)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(secondaryTextColor)
                                }
                            }
                        }
                    }
                    
                    if !detailText.isEmpty {
                        Text(detailText)
                            .font(.system(size: 14))
                            .foregroundColor(secondaryTextColor)
                    }
                    
                if includesTrial {
                    Text("3-day free trial included")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(trialAccentColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
            }
            .background(cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderStrokeColor, lineWidth: isSelected ? 2.5 : 1.2)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.45 : 0.25), radius: isSelected ? 14 : 8, x: 0, y: isSelected ? 12 : 8)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension SubscriptionCard {
    private var selectedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.31, green: 0.78, blue: 0.46),
                Color(red: 0.21, green: 0.63, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var unselectedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.15, blue: 0.13),
                Color(red: 0.07, green: 0.09, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardBackground: some View {
        Group {
            if isSelected {
                selectedGradient
            } else {
                unselectedGradient
            }
        }
    }

    private var borderStrokeColor: Color {
        if isSelected {
            return Color(red: 0.46, green: 0.92, blue: 0.6)
        } else {
            return Color.white.opacity(0.18)
        }
    }

    private var primaryTextColor: Color {
        isSelected ? .black : .white
    }

    private var secondaryTextColor: Color {
        isSelected ? Color.black.opacity(0.7) : Color.white.opacity(0.7)
    }

    private var trialAccentColor: Color {
        isSelected ? Color.black.opacity(0.75) : Color(red: 0.3, green: 0.7, blue: 0.4)
    }

    private var tagForegroundColor: Color {
        isSelected ? .black : Color(red: 0.3, green: 0.7, blue: 0.4)
    }

    private var tagBackgroundColor: Color {
        isSelected ? Color.white.opacity(0.3) : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15)
    }
}

private struct SubscriptionPlanOption: Identifiable {
    let id: String
    let title: String
    let price: String
    let priceSuffix: String
    let description: String
    let footnote: String
    let tagText: String?
    let tagColor: Color?
}

private let fallbackPlans: [SubscriptionPlanOption] = [
    SubscriptionPlanOption(
        id: "monthly",
        title: "Monthly",
        price: "$14.99",
        priceSuffix: "/ month",
        description: "Flexible access. Cancel anytime.",
        footnote: "3-day free trial, then $14.99/month.",
        tagText: nil,
        tagColor: nil
    ),
    SubscriptionPlanOption(
        id: "annual",
        title: "Annual",
        price: "$69.99",
        priceSuffix: "/ year",
        description: "Save 61%. Includes 3-day free trial.",
        footnote: "3-day free trial, then $69.99/year.",
        tagText: "Best Value",
        tagColor: Color(red: 0.3, green: 0.7, blue: 0.4)
    ),
    SubscriptionPlanOption(
        id: "lifetime",
        title: "Lifetime",
        price: "$249.99",
        priceSuffix: " one-time",
        description: "Pay once, own OffLeaf for life.",
        footnote: "$249.99 one-time payment. Lifetime access included.",
        tagText: nil,
        tagColor: nil
    )
]

private struct StaticSubscriptionCard: View {
    let plan: SubscriptionPlanOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(plan.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(primaryTextColor)
                        
                        if let tagText = plan.tagText {
                            Text(tagText)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(tagForegroundColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(tagBackgroundColor)
                                )
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(plan.price)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(primaryTextColor)
                    
                        if !plan.priceSuffix.isEmpty {
                            Text(plan.priceSuffix)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    
                    Text(plan.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
            }
            .background(cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderStrokeColor, lineWidth: isSelected ? 2.5 : 1.2)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.45 : 0.25), radius: isSelected ? 14 : 8, x: 0, y: isSelected ? 12 : 8)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        Group {
            if isSelected {
                LinearGradient(
                    colors: [
                        Color(red: 0.31, green: 0.78, blue: 0.46),
                        Color(red: 0.21, green: 0.63, blue: 0.36)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.15, blue: 0.13),
                        Color(red: 0.07, green: 0.09, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var primaryTextColor: Color {
        isSelected ? .black : .white
    }

    private var secondaryTextColor: Color {
        isSelected ? Color.black.opacity(0.7) : Color.white.opacity(0.75)
    }

    private var tagForegroundColor: Color {
        guard plan.tagText != nil else { return .clear }
        return isSelected ? .black : Color(red: 0.3, green: 0.7, blue: 0.4)
    }

    private var tagBackgroundColor: Color {
        guard plan.tagText != nil else { return .clear }
        return isSelected ? Color.white.opacity(0.3) : Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15)
    }

    private var borderStrokeColor: Color {
        isSelected ? Color(red: 0.46, green: 0.92, blue: 0.6) : Color.white.opacity(0.18)
    }
}

struct PricingView_Previews: PreviewProvider {
    static var previews: some View {
        PricingView(onComplete: {})
    }
}
