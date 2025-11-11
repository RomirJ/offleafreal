//
//  PremiumFeatureModifier.swift
//  Offleaf
//
//  Created by Assistant on 10/21/25.
//

import SwiftUI
import StoreKit

struct PremiumFeatureModifier: ViewModifier {
    @ObservedObject private var entitlementManager = EntitlementManager.shared
    @State private var showPremiumPrompt = false
    
    let feature: EntitlementManager.Feature
    let showUpgradePrompt: Bool
    
    init(feature: EntitlementManager.Feature, showUpgradePrompt: Bool = true) {
        self.feature = feature
        self.showUpgradePrompt = showUpgradePrompt
    }
    
    func body(content: Content) -> some View {
        Group {
            if entitlementManager.hasAccess(to: feature) {
                content
            } else {
                ZStack {
                    content
                        .blur(radius: 3)
                        .disabled(true)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text("Premium Feature")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Upgrade to premium to unlock this feature")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showPremiumPrompt = true
                        }) {
                            Text("Upgrade Now")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 200, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.9))
                    )
                    .padding()
                }
                .sheet(isPresented: $showPremiumPrompt) {
                    PremiumUpgradeView()
                }
            }
        }
        .onAppear {
            Task {
                await entitlementManager.verifyEntitlements()
            }
        }
    }
}

extension View {
    func requiresPremium(for feature: EntitlementManager.Feature, showUpgradePrompt: Bool = true) -> some View {
        self.modifier(PremiumFeatureModifier(feature: feature, showUpgradePrompt: showUpgradePrompt))
    }
}

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeKitManager = StoreKitManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Unlock Premium")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "book.fill", title: "Unlimited Journal Entries")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Statistics")
                            FeatureRow(icon: "bell.fill", title: "Custom Reminders")
                            FeatureRow(icon: "square.and.arrow.up.fill", title: "Export Your Data")
                            FeatureRow(icon: "phone.fill", title: "Emergency Contacts")
                            FeatureRow(icon: "doc.text.fill", title: "Trigger Planning")
                        }
                        .padding(.horizontal)
                        
                        if !storeKitManager.subscriptions.isEmpty {
                            VStack(spacing: 16) {
                                ForEach(storeKitManager.subscriptions.sorted(by: { $0.price < $1.price }), id: \.id) { product in
                                    Button(action: {
                                        selectedProduct = product
                                        Task {
                                            await purchaseSubscription()
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(product.displayName)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Text(product.description)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Text(product.displayPrice)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            Task {
                                await restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    @MainActor
    private func purchaseSubscription() async {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        
        do {
            let success = try await subscriptionManager.purchaseSubscription(product: product)
            if success {
                await EntitlementManager.shared.verifyEntitlements()
                dismiss()
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showError = true
        }
        
        isPurchasing = false
    }
    
    @MainActor
    private func restorePurchases() async {
        isPurchasing = true
        
        do {
            try await subscriptionManager.restorePurchases()
            await EntitlementManager.shared.verifyEntitlements()
            if subscriptionManager.hasActiveSubscription {
                dismiss()
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

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
