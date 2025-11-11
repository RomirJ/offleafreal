//
//  AboutSupportView.swift
//  Offleaf
//

import SwiftUI
import UIKit
import StoreKit
#if canImport(MessageUI)
import MessageUI
#endif

struct AboutSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingFAQ = false
    @State private var showingShareSheet = false
    private let shareMessage = "Check out Offleaf - an app that helps you quit cannabis and reclaim your life! 🌿\n\nDownload it here: https://apps.apple.com/app/offleaf"
#if canImport(MessageUI)
    @State private var showingMailComposer = false
#endif
    @State private var mailUnavailableAlert = false
    @State private var reviewUnavailableAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Info
                        VStack(spacing: 16) {
                            LeafLogoView(size: 80)
                            
                            Text("Offleaf")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Your journey to a cannabis-free life")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Support Options
                        VStack(spacing: 0) {
                            SupportButton(
                                icon: "envelope.fill",
                                title: "Contact Support",
                                subtitle: "Get help with any issues",
                                color: Color(red: 0.4, green: 0.6, blue: 1),
                                action: contactSupport
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            SupportButton(
                                icon: "questionmark.circle.fill",
                                title: "FAQ",
                                subtitle: "Common questions answered",
                                color: Color(red: 0.3, green: 0.7, blue: 0.4),
                                action: showFAQ
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            SupportButton(
                                icon: "star.fill",
                                title: "Rate Offleaf",
                                subtitle: "Share your experience",
                                color: Color(red: 0.9, green: 0.7, blue: 0.3),
                                action: rateApp
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            SupportButton(
                                icon: "person.2.fill",
                                title: "Share with Friends",
                                subtitle: "Help others quit too",
                                color: Color(red: 0.9, green: 0.3, blue: 0.3),
                                action: shareApp
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Resources
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RESOURCES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                ResourceLink(
                                    title: "Terms of Service",
                                    action: showTerms
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ResourceLink(
                                    title: "Privacy Policy",
                                    action: showPrivacy
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ResourceLink(
                                    title: "Acknowledgments",
                                    action: showAcknowledgments
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        
                        // Mission Statement
                        VStack(spacing: 16) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                            
                            Text("Our Mission")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("We believe everyone deserves support on their journey to quit cannabis. Offleaf is built with care to help you reclaim control of your life, one day at a time.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Social Links
                        HStack(spacing: 24) {
                            SocialButton(icon: "link", action: visitWebsite)
                            SocialButton(icon: "envelope", action: emailUs)
                        }
                        .padding(.top, 10)
                        
                        Text("Made with ❤️ for your wellness")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("About & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareMessage])
        }
#if canImport(MessageUI)
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["offleafapp@gmail.com"],
                subject: "Support Request",
                body: "Hi Offleaf Team,\n\n"
            )
        }
#endif
        .alert("Mail Unavailable", isPresented: $mailUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't open Mail on this device. Please email us at offleafapp@gmail.com.")
        }
        .alert("Unable to Request Review", isPresented: $reviewUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please search for Offleaf on the App Store to leave a review.")
        }
    }
    
    private func contactSupport() {
        let encodedBody = "Hi Offleaf Team,\n\n".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:offleafapp@gmail.com?subject=Support%20Request&body=\(encodedBody)"
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
    
    private func showFAQ() {
        showingFAQ = true
    }
    
    private func rateApp() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
                reviewUnavailableAlert = true
                return
            }

        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: windowScene)
        } else {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func shareApp() {
        showingShareSheet = true
    }
    
    private func showTerms() {
        openLegalHub()
    }
    
    private func showPrivacy() {
        openLegalHub()
    }
    
    private func showAcknowledgments() {
        openLegalHub()
    }
    
    private func visitWebsite() {
        openLegalHub()
    }
    
    private func openLegalHub() {
        if let url = URL(string: "https://offleaf-legal-hub.lovable.app/") {
            UIApplication.shared.open(url)
        }
    }
    
    private func emailUs() {
        contactSupport()
    }
}

struct SupportButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResourceLink: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SocialButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
        }
    }
}

#if canImport(MessageUI)
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let recipients: [String]
    let subject: String
    let body: String

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            dismiss()
        }
    }
}
#endif

struct AboutSupportView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSupportView()
    }
}
