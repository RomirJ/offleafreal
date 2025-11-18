//
//  FAQView.swift
//  Offleaf
//

import SwiftUI
import UIKit
#if canImport(MessageUI)
import MessageUI
#endif

struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandedItems: Set<Int> = []
    @State private var mailUnavailableAlert = false
#if canImport(MessageUI)
    @State private var showingMailComposer = false
#endif
    
    let faqItems = [
        FAQItem(
            question: "How does Offleaf help me quit cannabis?",
            answer: "Offleaf provides a comprehensive approach to quitting cannabis through daily mood tracking, craving management tools, personalized insights, motivational reminders, and progress tracking. Our app helps you understand your usage patterns and provides support when you need it most."
        ),
        FAQItem(
            question: "Is my data private and secure?",
            answer: "Yes! All your personal data is stored locally on your device and encrypted. We never sell or share your information with third parties. You can enable passcode and biometric protection for additional security, and you have full control to export or delete your data at any time."
        ),
        FAQItem(
            question: "What is the 'I Need Help' button for?",
            answer: "The 'I Need Help' button provides immediate support during cravings or difficult moments. Tapping it gives you access to breathing exercises, distraction techniques, motivational content, and emergency contacts. The SOS feature can quickly connect you with your support network."
        ),
        FAQItem(
            question: "How do I track my progress?",
            answer: "Your progress is automatically tracked from your quit date. You can view days clean, money saved, and time reclaimed in the Progress tab. The app also tracks your mood patterns and craving intensity over time to show your improvement journey."
        ),
        FAQItem(
            question: "Can I customize my quit plan?",
            answer: "Yes! During onboarding, you can set your quit date, specify your usage patterns, and choose your reduction approach. You can update these settings anytime in your Profile under 'Plan Summary' or 'Personal Information'."
        ),
        FAQItem(
            question: "What are milestones?",
            answer: "Milestones are achievements you unlock as you progress in your journey. They celebrate important markers like your first 24 hours, one week, one month, and beyond. Each milestone represents a significant step toward your cannabis-free life."
        ),
        FAQItem(
            question: "How do notifications work?",
            answer: "You can customize notifications for daily check-ins, motivational quotes, and milestone reminders. Set your preferred check-in time and choose which types of notifications you want to receive. All notifications can be managed in Profile > Notifications."
        ),
        FAQItem(
            question: "What's included in the free version?",
            answer: "The free version includes core features like progress tracking, mood logging, the 'I Need Help' button, and basic insights. Premium unlocks unlimited journal entries, advanced analytics, community support, and personalized quit plans."
        ),
        FAQItem(
            question: "Can I use Offleaf offline?",
            answer: "Yes! Most features work offline since your data is stored locally. Some features like community support and cloud backup require an internet connection. Your progress and journal entries are always available offline."
        ),
        FAQItem(
            question: "How do I reset my progress?",
            answer: "If you need to start over, you can reset your quit date in Personal Information, or completely delete all data in Privacy & Security settings. Remember, relapses are part of the journey - you can always begin again."
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(faqItems.enumerated()), id: \.offset) { index, item in
                            FAQItemView(
                                item: item,
                                isExpanded: expandedItems.contains(index),
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if expandedItems.contains(index) {
                                            expandedItems.remove(index)
                                        } else {
                                            expandedItems.insert(index)
                                        }
                                    }
                                }
                            )
                        }
                        
                        // Contact support section
                        VStack(spacing: 16) {
                            Text("Still have questions?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Button(action: contactSupport) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16))
                                    
                                    Text("Contact Support")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                )
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
#if canImport(MessageUI)
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["offleafapp@gmail.com"],
                subject: "FAQ Question",
                body: "Hi Offleaf Team,\n\n"
            )
        }
#endif
        .alert("Mail Unavailable", isPresented: $mailUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't open Mail on this device. Please email us at offleafapp@gmail.com.")
        }
    }
    
    private func contactSupport() {
        let encodedBody = "Hi Offleaf Team,\n\n".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:offleafapp@gmail.com?subject=FAQ%20Question&body=\(encodedBody)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
#if canImport(MessageUI)
            if MFMailComposeViewController.canSendMail() {
                showingMailComposer = true
            } else {
                mailUnavailableAlert = true
            }
#else
            mailUnavailableAlert = true
#endif
        }
    }
}

struct FAQItem {
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .animation(.easeInOut, value: isExpanded)
                }
                
                if isExpanded {
                    Text(item.answer)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
