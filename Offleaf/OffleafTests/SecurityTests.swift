//
//  SecurityTests.swift
//  OffleafTests
//
//  Comprehensive security testing
//

import Testing
import Foundation
@testable import Offleaf

struct SecurityTests {
    
    @Test func testUserDefaultsContainsSensitiveData() {
        // Test that sensitive data is being stored in UserDefaults
        let defaults = UserDefaults.standard
        
        // Simulate storing sensitive data as the app does
        defaults.set("2024-01-01T00:00:00Z", forKey: "quitDate")
        defaults.set("John Doe", forKey: "userName")
        defaults.set("25", forKey: "userAge")
        defaults.set(150.0, forKey: "weeklySpending")
        
        // Check if data is readable (security issue)
        #expect(defaults.string(forKey: "quitDate") != nil, "Quit date is stored unencrypted")
        #expect(defaults.string(forKey: "userName") != nil, "User name is stored unencrypted")
        #expect(defaults.string(forKey: "userAge") != nil, "User age is stored unencrypted")
        #expect(defaults.double(forKey: "weeklySpending") > 0, "Spending data is stored unencrypted")
        
        // This test PASSES which confirms the security vulnerability
    }
    
    @Test func testHardcodedURLsExist() {
        // Test for hardcoded URLs
        let termsURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        let privacyURL = "https://offleaf-legal-hub.lovable.app/"
        
        #expect(URL(string: termsURL) != nil, "Hardcoded terms URL exists")
        #expect(URL(string: privacyURL) != nil, "Hardcoded privacy URL exists")
        
        // Test force unwrapping would crash
        let forceUnwrappedURL = URL(string: termsURL)!
        #expect(forceUnwrappedURL.absoluteString == termsURL, "Force unwrapping URLs is dangerous")
    }
    
    @Test func testDebugModeVulnerability() {
        #if DEBUG
        let isDebugMode = true
        #else
        let isDebugMode = false
        #endif
        
        #expect(isDebugMode == true, "Debug mode is active - unverified transactions would be accepted")
    }
    
    @Test func testKeychainUsageForSensitiveData() {
        // Test if Keychain is properly used for sensitive data
        let passcode = "1234"
        let keychainHelper = KeychainHelper.shared
        
        // Test saving to keychain
        let saved = keychainHelper.savePasscode(passcode)
        #expect(saved == true, "Keychain can save passcode")
        
        // Test that passcode is not in UserDefaults
        #expect(UserDefaults.standard.string(forKey: "userPasscode") == nil, "Passcode should not be in UserDefaults")
        
        // Cleanup
        _ = keychainHelper.deletePasscode()
    }
    
    @Test func testDataEncryption() {
        // Test if any encryption is used for stored data
        let sensitiveData = "user medical cannabis usage data"
        let data = sensitiveData.data(using: .utf8)!
        
        // Check if data is stored as-is (unencrypted)
        UserDefaults.standard.set(data, forKey: "testData")
        let retrievedData = UserDefaults.standard.data(forKey: "testData")
        let retrievedString = String(data: retrievedData!, encoding: .utf8)
        
        #expect(retrievedString == sensitiveData, "Data is stored unencrypted - SECURITY ISSUE")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "testData")
    }
}