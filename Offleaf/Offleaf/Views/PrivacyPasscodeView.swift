//
//  PrivacyPasscodeView.swift
//  Offleaf
//

import SwiftUI
import LocalAuthentication
import UIKit

struct PrivacyPasscodeView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("passcodeEnabled") private var passcodeEnabled = false
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("hideNotificationContent") private var hideNotificationContent = false
    
    @State private var showingPasscodeSetup = false
    @State private var showingPasscodeEntry = false
    @State private var showingExportSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingPrivacyPolicy = false
    @State private var biometricType = ""
    @State private var passcode = ""
    @State private var confirmPasscode = ""
    @State private var passcodeError = ""
    @State private var exportedData = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Lock Section
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("APP SECURITY")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 20)
                            }
                            
                            Toggle(isOn: $passcodeEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Require Passcode")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Lock the app with a passcode")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                            .padding(.horizontal, 20)
                            .onChange(of: passcodeEnabled) { oldValue, enabled in
                                if enabled && !KeychainHelper.shared.hasPasscode() {
                                    showingPasscodeSetup = true
                                } else if !enabled {
                                    // Clear passcode when disabled
                                    _ = KeychainHelper.shared.deletePasscode()
                                    biometricEnabled = false
                                }
                            }
                            
                            if passcodeEnabled && KeychainHelper.shared.hasPasscode() {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.horizontal, 20)
                                
                                Toggle(isOn: $biometricEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Use \(biometricType)")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("Unlock with biometric authentication")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                                .padding(.horizontal, 20)
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.horizontal, 20)
                                
                                Button(action: { showingPasscodeSetup = true }) {
                                    HStack {
                                        Text("Change Passcode")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Privacy Section
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PRIVACY")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 20)
                            }
                            
                            Toggle(isOn: $hideNotificationContent) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hide Notification Content")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Show generic text in notifications")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Data Management
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DATA MANAGEMENT")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 20)
                            }
                            
                            Button(action: exportData) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1))
                                    
                                    Text("Export My Data")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            Button(action: { showingDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                        .foregroundColor(.red)
                                    
                                    Text("Delete All Data")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red.opacity(0.5))
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Privacy Policy
                        Button(action: { showingPrivacyPolicy = true }) {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(size: 16))
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
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Privacy & Security")
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
        .onAppear {
            checkBiometricType()
        }
        .sheet(isPresented: $showingPasscodeSetup) {
            PasscodeSetupView(
                passcode: $passcode,
                confirmPasscode: $confirmPasscode,
                passcodeEnabled: $passcodeEnabled,
                isPresented: $showingPasscodeSetup
            )
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(items: [exportedData])
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .alert("Delete All Data", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your data including progress, journal entries, and settings. This action cannot be undone.")
        }
    }
    
    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = "Face ID"
            case .touchID:
                biometricType = "Touch ID"
            case .opticID:
                biometricType = "Optic ID"
            case .none:
                biometricType = "Biometric"
            @unknown default:
                biometricType = "Biometric"
            }
        }
    }
    
    private func exportData() {
        // Collect only user-relevant data
        var dataToExport = [String: Any]()
        
        // Only export user-specific data, not internal app state
        let userDataKeys = [
            "name", "quitDate", "weeklySpending", "smokeFrequency",
            "assessmentPrimaryUseReason", "assessmentTimeSpentObtaining",
            "assessmentStrongCravings", "assessmentLostInterest",
            "assessmentConcernedLovedOnes", "assessmentFeelsGuilty",
            "assessmentToleranceIncrease", "assessmentQuitReadinessLevel",
            "assessmentQuitConfidenceLevel", "assessmentMotivationArea",
            "triggers", "userQuitReasons", "journalEntries",
            "dailyCheckInEnabled", "motivationalQuotesEnabled",
            "milestoneRemindersEnabled", "cravingTipsEnabled",
            "checkInTime", "hideNotificationContent", "dailyCheckInEntries"
        ]
        
        for key in userDataKeys {
            if let value = UserDefaults.standard.object(forKey: key) {
                dataToExport[key] = value
            }
        }
        
        // Add metadata
        dataToExport["exportDate"] = ISO8601DateFormatter().string(from: Date())
        dataToExport["appVersion"] = "1.0.0"
        
        // Remove sensitive internal data
        dataToExport.removeValue(forKey: "passcodeEnabled")
        dataToExport.removeValue(forKey: "biometricEnabled")
        
        // Convert to JSON
        do {
            let safeObject = makeJSONSafe(dataToExport)
            let jsonData = try JSONSerialization.data(withJSONObject: safeObject, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                exportedData = jsonString
                showingExportSheet = true
            }
        } catch {
            exportedData = "{\n  \"error\": \"Unable to export data: \(error.localizedDescription)\"\n}"
            showingExportSheet = true
        }
    }

    private func makeJSONSafe(_ object: Any) -> Any {
        switch object {
        case let dict as [String: Any]:
            var safeDict = [String: Any]()
            for (key, value) in dict {
                safeDict[key] = makeJSONSafe(value)
            }
            return safeDict
        case let array as [Any]:
            return array.map(makeJSONSafe)
        case let data as Data:
            if let decoded = try? JSONSerialization.jsonObject(with: data, options: []) {
                return makeJSONSafe(decoded)
            } else if let decodedString = String(data: data, encoding: .utf8) {
                return decodedString
            } else {
                return data.base64EncodedString()
            }
        case let date as Date:
            return ISO8601DateFormatter().string(from: date)
        case let number as NSNumber:
            return number
        case let string as String:
            return string
        case let bool as Bool:
            return bool
        default:
            return String(describing: object)
        }
    }
    
    private func deleteAllData() {
        // Clear all UserDefaults
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
        
        // Reset to initial state
        passcodeEnabled = false
        biometricEnabled = false
        hideNotificationContent = false
        _ = KeychainHelper.shared.deletePasscode()
        
        // Dismiss and return to main screen
        dismiss()
    }
}

// Passcode Setup View
struct PasscodeSetupView: View {
    @Binding var passcode: String
    @Binding var confirmPasscode: String
    @Binding var passcodeEnabled: Bool
    @Binding var isPresented: Bool
    
    @State private var step = 1
    @State private var error = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text(step == 1 ? "Enter Passcode" : "Confirm Passcode")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Passcode dots
                    HStack(spacing: 20) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(getPasscodeForStep().count > index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 15, height: 15)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    if !error.isEmpty {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    // Number pad
                    VStack(spacing: 20) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 40) {
                                ForEach(1...3, id: \.self) { col in
                                    let number = row * 3 + col
                                    NumberButton(number: "\(number)") {
                                        addNumber("\(number)")
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 40) {
                            Button(action: clearPasscode) {
                                Text("Clear")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 70, height: 70)
                            }
                            
                            NumberButton(number: "0") {
                                addNumber("0")
                            }
                            
                            Button(action: deleteLastNumber) {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 70, height: 70)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        passcodeEnabled = KeychainHelper.shared.hasPasscode()
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private func getPasscodeForStep() -> String {
        step == 1 ? passcode : confirmPasscode
    }
    
    private func addNumber(_ number: String) {
        error = ""
        
        if step == 1 {
            if passcode.count < 4 {
                passcode += number
                if passcode.count == 4 {
                    step = 2
                }
            }
        } else {
            if confirmPasscode.count < 4 {
                confirmPasscode += number
                if confirmPasscode.count == 4 {
                    validatePasscode()
                }
            }
        }
    }
    
    private func deleteLastNumber() {
        if step == 1 && !passcode.isEmpty {
            passcode.removeLast()
        } else if step == 2 && !confirmPasscode.isEmpty {
            confirmPasscode.removeLast()
        }
    }
    
    private func clearPasscode() {
        if step == 1 {
            passcode = ""
        } else {
            confirmPasscode = ""
        }
        error = ""
    }
    
    private func validatePasscode() {
        if passcode == confirmPasscode {
            _ = KeychainHelper.shared.savePasscode(passcode)
            passcodeEnabled = true
            isPresented = false
        } else {
            error = "Passcodes don't match"
            confirmPasscode = ""
        }
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                )
        }
    }
}

// Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Last updated: January 2025")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            PrivacySectionView(
                                title: "Information We Collect",
                                content: "Offleaf collects minimal personal information necessary to provide you with a personalized experience. This includes your name, quit date, usage patterns, and progress data. All information is stored locally on your device."
                            )
                            
                            PrivacySectionView(
                                title: "How We Use Your Information",
                                content: "Your information is used solely to track your progress, provide personalized insights, and send you helpful reminders. We never sell or share your personal data with third parties."
                            )
                            
                            PrivacySectionView(
                                title: "Data Storage",
                                content: "All your data is stored locally on your device. If you choose to enable iCloud backup, your data will be securely synced across your devices using Apple's encrypted iCloud services."
                            )
                            
                            PrivacySectionView(
                                title: "Your Rights",
                                content: "You have complete control over your data. You can export your data at any time, delete all data from the app, or disable specific features that collect information."
                            )
                            
                            PrivacySectionView(
                                title: "Contact Us",
                                content: "If you have any questions about this Privacy Policy, please contact us at offleafapp@gmail.com"
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

struct PrivacySectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(.bottom, 8)
    }
}

// Share Sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PrivacyPasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPasscodeView()
    }
}
