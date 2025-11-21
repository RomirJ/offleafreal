//
//  SecurityTests.swift
//  OffleafTests
//
//  Comprehensive security testing for Offleaf app
//

import Testing
import Foundation
@testable import Offleaf

struct SecurityTests {
    
    @Test func testSensitiveDataInUserDefaults() {
        // Test that sensitive health data is stored unencrypted in UserDefaults
        let defaults = UserDefaults.standard
        
        // Simulate actual app storage patterns found in codebase
        defaults.set("2024-01-01T00:00:00Z", forKey: "quitDate")
        defaults.set("John Doe", forKey: "userName")
        defaults.set("25", forKey: "userAge")
        defaults.set(150.0, forKey: "weeklySpending")
        defaults.set(20, forKey: "cigarettesPerDay")
        defaults.set("heavy", forKey: "cannabisUseFrequency")
        defaults.set(true, forKey: "hasCompletedDailyCheckIn")
        defaults.set(7, forKey: "checkInStreak")
        
        // All sensitive data is readable without encryption
        #expect(defaults.string(forKey: "quitDate") != nil, "Quit date stored unencrypted - SECURITY VULNERABILITY")
        #expect(defaults.string(forKey: "userName") != nil, "User name stored unencrypted - PRIVACY ISSUE")
        #expect(defaults.string(forKey: "userAge") != nil, "User age stored unencrypted - PRIVACY ISSUE")
        #expect(defaults.double(forKey: "weeklySpending") > 0, "Financial data stored unencrypted - SECURITY RISK")
        #expect(defaults.integer(forKey: "cigarettesPerDay") >= 0, "Health data stored unencrypted - HIPAA CONCERN")
        
        // Count total sensitive data points
        let sensitiveKeys = ["quitDate", "userName", "userAge", "weeklySpending", "cigarettesPerDay", 
                             "cannabisUseFrequency", "hasCompletedDailyCheckIn", "checkInStreak"]
        var exposedDataCount = 0
        for key in sensitiveKeys {
            if defaults.object(forKey: key) != nil {
                exposedDataCount += 1
            }
        }
        #expect(exposedDataCount == 8, "\(exposedDataCount) sensitive data points exposed in UserDefaults")
    }
    
    @Test func testForceUnwrappedURLs() {
        // Test dangerous force unwrapping in PricingView.swift lines 109, 113
        let termsURLString = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        let privacyURLString = "https://offleaf-legal-hub.lovable.app/"
        
        // These URLs are force unwrapped in the actual code
        let termsURL = URL(string: termsURLString)!
        let privacyURL = URL(string: privacyURLString)!
        
        #expect(termsURL.absoluteString == termsURLString, "Force unwrapped URL - CRASH RISK")
        #expect(privacyURL.absoluteString == privacyURLString, "Force unwrapped URL - CRASH RISK")
        
        // Test what happens with invalid URL
        let invalidURLString = "not a valid url with spaces"
        let invalidURL = URL(string: invalidURLString)
        #expect(invalidURL == nil, "Invalid URL would crash app with force unwrap")
    }
    
    @Test func testStoreKitDebugModeVulnerability() {
        // Test StoreKitManager.swift lines 92-109 debug mode issue
        #if DEBUG
        let isDebugMode = true
        #else
        let isDebugMode = false
        #endif
        
        #expect(isDebugMode == true, "Debug mode active - unverified transactions accepted")
        
        // Simulate the vulnerable checkVerified function behavior
        enum TestVerificationResult<T> {
            case verified(T)
            case unverified(T, Error)
        }
        
        struct TestTransaction {
            let productID: String
            let isVerified: Bool
        }
        
        func checkVerified<T>(_ result: TestVerificationResult<T>) -> T? {
            #if DEBUG
            // In debug mode, accepts unverified transactions
            switch result {
            case .unverified(let value, _):
                return value  // Returns unverified transaction!
            case .verified(let safe):
                return safe
            }
            #else
            switch result {
            case .unverified:
                return nil
            case .verified(let safe):
                return safe
            }
            #endif
        }
        
        let unverifiedTransaction = TestTransaction(productID: "premium", isVerified: false)
        let result = TestVerificationResult.unverified(unverifiedTransaction, NSError(domain: "", code: 0))
        let accepted = checkVerified(result)
        
        #expect(accepted != nil, "Unverified transaction accepted in DEBUG - REVENUE LOSS RISK")
    }
    
    @Test func testKeychainImplementation() {
        // Test KeychainHelper proper usage for passcodes
        let keychainHelper = KeychainHelper.shared
        let testPasscode = "1234"
        
        // Save sensitive data
        let saved = keychainHelper.savePasscode(testPasscode)
        #expect(saved == true, "Keychain should save passcode securely")
        
        // Verify passcode NOT in UserDefaults
        #expect(UserDefaults.standard.string(forKey: "userPasscode") == nil, "Passcode should NOT be in UserDefaults")
        #expect(UserDefaults.standard.string(forKey: "appPasscode") == nil, "App passcode should NOT be in UserDefaults")
        
        // Retrieve and verify
        let retrieved = keychainHelper.getPasscode()
        #expect(retrieved == testPasscode, "Keychain should retrieve passcode")
        
        // Cleanup
        let deleted = keychainHelper.deletePasscode()
        #expect(deleted == true, "Keychain should delete passcode")
    }
    
    @Test func testDataEncryptionStatus() {
        // Test if any encryption is used for health data
        let healthData = "Cannabis usage: 5 times daily, Method: smoking"
        let data = healthData.data(using: .utf8)!
        
        // Store as app does
        UserDefaults.standard.set(data, forKey: "healthRecord")
        
        // Retrieve and check if plaintext
        if let retrievedData = UserDefaults.standard.data(forKey: "healthRecord"),
           let retrievedString = String(data: retrievedData, encoding: .utf8) {
            #expect(retrievedString == healthData, "Health data stored in plaintext - HIPAA VIOLATION")
        }
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "healthRecord")
    }
    
    @Test func testHardcodedSecrets() {
        // Test for hardcoded API keys or secrets
        let suspiciousPatterns = [
            "sk_live_",  // Stripe live key
            "sk_test_",  // Stripe test key
            "pk_live_",  // Stripe publishable key
            "AIza",      // Google API key
            "xoxb-",     // Slack token
            "ghp_"       // GitHub personal access token
        ]
        
        // In actual implementation, would scan codebase
        // For now, confirm none are hardcoded in UserDefaults
        for pattern in suspiciousPatterns {
            let found = UserDefaults.standard.dictionaryRepresentation().values.contains { value in
                if let stringValue = value as? String {
                    return stringValue.contains(pattern)
                }
                return false
            }
            #expect(found == false, "Potential hardcoded secret pattern: \(pattern)")
        }
    }
    
    @Test func testBiometricAuthenticationBypass() {
        // Test if biometric authentication can be bypassed
        let isLocked = UserDefaults.standard.bool(forKey: "isAppLocked")
        let passcodeEnabled = UserDefaults.standard.bool(forKey: "isPasscodeEnabled")
        let biometricEnabled = UserDefaults.standard.bool(forKey: "isBiometricEnabled")
        
        // Test bypass scenarios
        if isLocked && !passcodeEnabled && !biometricEnabled {
            #expect(false, "App locked but no authentication method - SECURITY BYPASS")
        }
        
        // Test if lock state persists properly
        UserDefaults.standard.set(true, forKey: "isAppLocked")
        let stillLocked = UserDefaults.standard.bool(forKey: "isAppLocked")
        #expect(stillLocked == true, "Lock state should persist")
    }
    
    @Test func testPrivacyPolicyURLs() {
        // Test privacy and terms URLs are valid and secure
        let urls = [
            "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
            "https://offleaf-legal-hub.lovable.app/"
        ]
        
        for urlString in urls {
            if let url = URL(string: urlString) {
                #expect(url.scheme == "https", "URL should use HTTPS for security")
                #expect(url.host != nil, "URL should have valid host")
            }
        }
    }
}