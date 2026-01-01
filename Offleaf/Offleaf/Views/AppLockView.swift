//
//  AppLockView.swift
//  Offleaf
//

import SwiftUI
import LocalAuthentication
import UIKit

struct AppLockView: View {
    @Binding var isUnlocked: Bool
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    
    @State private var passcode = ""
    @State private var error = ""
    @State private var isShowingPasscode = false
    
    // Persistent lockout using AppStorage
    @AppStorage("lockoutAttempts") private var attempts = 0
    @AppStorage("lockoutEndTimeInterval") private var lockoutEndTimeInterval: Double = 0
    
    private var lockoutEndTime: Date? {
        lockoutEndTimeInterval > 0 ? Date(timeIntervalSince1970: lockoutEndTimeInterval) : nil
    }
    
    private var isLockedOut: Bool {
        if let lockoutEnd = lockoutEndTime {
            return Date() < lockoutEnd
        }
        return false
    }
    
    var body: some View {
        ZStack {
            // Blur background
            Color.black
                .ignoresSafeArea()
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white.opacity(0.1))
                )
            
            if !isShowingPasscode {
                // Initial lock screen
                VStack(spacing: 30) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Offleaf is Locked")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if biometricEnabled {
                        Button(action: authenticateWithBiometric) {
                            HStack {
                                Image(systemName: getBiometricIcon())
                                    .font(.system(size: 20))
                                
                                Text("Unlock with \(BiometricAuthManager.shared.getBiometricTypeString())")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                        }
                    }
                    
                    Button(action: { isShowingPasscode = true }) {
                        Text("Enter Passcode")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .onAppear {
                    if biometricEnabled {
                        // Auto-trigger biometric on appear
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            authenticateWithBiometric()
                        }
                    } else {
                        isShowingPasscode = true
                    }
                }
            } else {
                // Passcode entry screen
                VStack(spacing: 30) {
                    Text("Enter Passcode")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Passcode dots
                    HStack(spacing: 20) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(passcode.count > index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 15, height: 15)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    if !error.isEmpty {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .animation(.easeInOut, value: error)
                    }
                    
                    // Number pad
                    VStack(spacing: 20) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 40) {
                                ForEach(1...3, id: \.self) { col in
                                    let number = row * 3 + col
                                    NumberPadButton(number: "\(number)") {
                                        addNumber("\(number)")
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 40) {
                            // Cancel button (if biometric is available)
                            if biometricEnabled {
                                Button(action: { isShowingPasscode = false }) {
                                    Text("Cancel")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 70, height: 70)
                                }
                            } else {
                                Color.clear.frame(width: 70, height: 70)
                            }
                            
                            NumberPadButton(number: "0") {
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
        }
    }
    
    private func getBiometricIcon() -> String {
        switch BiometricAuthManager.shared.getBiometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.fill"
        }
    }
    
    private func authenticateWithBiometric() {
        BiometricAuthManager.shared.authenticateWithBiometric(reason: "Unlock Offleaf") { success, error in
            if success {
                withAnimation {
                    isUnlocked = true
                }
            } else {
                // Don't automatically fall back - show error instead
                if error != nil {
                    self.error = "Biometric authentication failed. Tap 'Enter Passcode' to use passcode."
                }
                // User must explicitly choose to use passcode
            }
        }
    }
    
    private func addNumber(_ number: String) {
        guard passcode.count < 4 else { return }
        
        passcode += number
        error = ""
        
        if passcode.count == 4 {
            validatePasscode()
        }
    }
    
    private func deleteLastNumber() {
        if !passcode.isEmpty {
            passcode.removeLast()
            error = ""
        }
    }
    
    private func validatePasscode() {
        // Check if currently locked out
        if isLockedOut, let lockoutEnd = lockoutEndTime {
            let remaining = Int(lockoutEnd.timeIntervalSinceNow)
            if remaining > 0 {
                error = "Locked out. Try again in \(remaining) seconds"
                passcode = ""
                return
            } else {
                // Lockout expired, reset
                lockoutEndTimeInterval = 0
                attempts = 0
            }
        }
        
        if KeychainHelper.shared.verifyPasscode(passcode) {
            // Reset attempts on successful unlock
            attempts = 0
            lockoutEndTimeInterval = 0
            withAnimation {
                isUnlocked = true
            }
        } else {
            attempts += 1
            passcode = ""
            
            // Haptic feedback for wrong passcode
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Exponential backoff lockout with persistence
            switch attempts {
            case 3:
                lockoutEndTimeInterval = Date().addingTimeInterval(60).timeIntervalSince1970 // 1 minute
                error = "Too many attempts. Locked for 1 minute."
            case 5:
                lockoutEndTimeInterval = Date().addingTimeInterval(300).timeIntervalSince1970 // 5 minutes
                error = "Too many attempts. Locked for 5 minutes."
            case 7:
                lockoutEndTimeInterval = Date().addingTimeInterval(900).timeIntervalSince1970 // 15 minutes
                error = "Too many attempts. Locked for 15 minutes."
            case 10...:
                lockoutEndTimeInterval = Date().addingTimeInterval(3600).timeIntervalSince1970 // 1 hour
                error = "Too many attempts. Locked for 1 hour."
            default:
                error = "Incorrect passcode (\(attempts) attempt\(attempts == 1 ? "" : "s"))"
            }
        }
    }
}

struct NumberPadButton: View {
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

struct AppLockView_Previews: PreviewProvider {
    static var previews: some View {
        AppLockView(isUnlocked: .constant(false))
    }
}
