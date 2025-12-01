//
//  ProfileView.swift
//  Offleaf
//
//  Created by Assistant on 10/11/25.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    // Navigation states
    @State private var showingPlanSummary = false
    @State private var showingPersonalInfo = false
    @State private var showingMyReasons = false
    @State private var showingNotifications = false
    @State private var showingPrivacy = false
    @State private var showingAbout = false
    @State private var showingSubscription = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    LeafLogoView(size: 60)
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Plan Summary
                        Button(action: { showingPlanSummary = true }) {
                            ProfileRow(
                                title: "Plan summary",
                                subtitle: "Week X focus",
                                icon: nil
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Personal Information
                        Button(action: { showingPersonalInfo = true }) {
                            ProfileRow(
                                title: "Personal Information",
                                subtitle: nil,
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // My Reasons
                        Button(action: { showingMyReasons = true }) {
                            ProfileRow(
                                title: "My Reasons",
                                subtitle: nil,
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Notifications
                        Button(action: { showingNotifications = true }) {
                            ProfileRow(
                                title: "Notifications",
                                subtitle: nil,
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Privacy & Passcode
                        Button(action: { showingPrivacy = true }) {
                            ProfileRow(
                                title: "Privacy & Passcode",
                                subtitle: nil,
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // About & Support
                        Button(action: { showingAbout = true }) {
                            ProfileRow(
                                title: "About & Support",
                                subtitle: nil,
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Subscription
                        Button(action: { showingSubscription = true }) {
                            ProfileRow(
                                title: "Subscription",
                                subtitle: subscriptionManager.getSubscriptionStatus(),
                                icon: "chevron.right"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Log Out Button
                        Button(action: {
                            // Reset onboarding and subscription
                            hasCompletedOnboarding = false
                            subscriptionManager.resetSubscription()
                        }) {
                            HStack {
                                Text("Log Out")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 150)
                }
            }
        }
        .fullScreenCover(isPresented: $showingPlanSummary) {
            PlanSummaryView()
        }
        .fullScreenCover(isPresented: $showingPersonalInfo) {
            PersonalInformationView()
        }
        .fullScreenCover(isPresented: $showingMyReasons) {
            MyReasonsView()
        }
        .fullScreenCover(isPresented: $showingNotifications) {
            NotificationsSettingsView()
        }
        .fullScreenCover(isPresented: $showingPrivacy) {
            PrivacyPasscodeView()
        }
        .fullScreenCover(isPresented: $showingAbout) {
            AboutSupportView()
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            SubscriptionDetailView()
        }
    }
}

struct ProfileRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, subtitle != nil ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
