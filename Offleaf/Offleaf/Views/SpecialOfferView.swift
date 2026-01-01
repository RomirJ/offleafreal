//
//  SpecialOfferView.swift
//  Offleaf
//
//  Special one-time offer after wheel spin
//

import SwiftUI
import StoreKit

struct SpecialOfferView: View {
    @ObservedObject private var storeKitManager = StoreKitManager.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var freeTrialEnabled = true
    @State private var starsOpacity = 0.0
    
    var onDismiss: () -> Void
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
                
                // Title
                Text("Your one-time offer")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Discount card with stars
                ZStack {
                    // Decorative stars
                    ForEach(0..<4, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: index % 2 == 0 ? 50 : 30))
                            .foregroundColor(index % 2 == 0 ? .black : .white.opacity(0.3))
                            .offset(
                                x: index == 0 ? -140 : index == 1 ? 140 : index == 2 ? -120 : 120,
                                y: index == 0 ? -20 : index == 1 ? 20 : index == 2 ? 60 : -60
                            )
                            .opacity(starsOpacity)
                    }
                    
                    // Main offer card
                    VStack(spacing: 8) {
                        Text("80% OFF")
                            .font(.system(size: 52, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("FOREVER")
                            .font(.system(size: 44, weight: .black))
                            .foregroundColor(.white)
                    }
                    .frame(width: 320, height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.2, blue: 0.2),
                                        Color(red: 0.15, green: 0.15, blue: 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.white.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.top, 40)
                
                // Pricing
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("$29.99")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .strikethrough(true, color: .white.opacity(0.5))
                    
                    Text("$1.66 /mo")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                
                Spacer()
                
                // Warning text
                VStack(spacing: 8) {
                    Text("Once you close your one-time offer, it's gone!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Save 80% with yearly plan")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Free trial toggle
                HStack {
                    Text("Free Trial Enabled")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $freeTrialEnabled)
                        .labelsHidden()
                        .tint(Color(red: 0.3, green: 0.8, blue: 0.5))
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                // Subscription card
                VStack(spacing: 0) {
                    // Trial header
                    if freeTrialEnabled {
                        Text("3-DAY FREE TRIAL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.3, green: 0.8, blue: 0.5))
                    }
                    
                    // Plan details
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yearly Plan")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("12mo • $19.99")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Text("$1.66 /mo")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white)
                }
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // CTA Button
                Button(action: {
                    Task {
                        await purchaseSpecialOffer()
                    }
                }) {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.4))
                            .cornerRadius(30)
                    } else {
                        Text("Start Free Trial")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.8, blue: 0.5),
                                        Color(red: 0.25, green: 0.7, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(30)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .disabled(isPurchasing)
                
                // No commitment text
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    
                    Text("No Commitment - Cancel Anytime")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                starsOpacity = 1.0
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    @MainActor
    private func purchaseSpecialOffer() async {
        // Load products if needed
        await storeKitManager.loadProducts()
        
        // Get the special annual product
        guard let product = storeKitManager.product(withID: StoreKitManager.ProductID.specialAnnual.rawValue) else {
            errorMessage = "Special offer not available. Please try again."
            showError = true
            return
        }
        
        isPurchasing = true
        
        do {
            let transaction = try await storeKitManager.purchase(product)
            if transaction != nil {
                // Purchase successful
                onComplete()
            } else {
                // User cancelled
                isPurchasing = false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showError = true
            isPurchasing = false
        }
    }
}

struct SpecialOfferView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialOfferView(
            onDismiss: {},
            onComplete: {}
        )
    }
}