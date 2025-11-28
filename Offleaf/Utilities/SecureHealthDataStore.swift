//
//  SecureHealthDataStore.swift
//  Offleaf
//
//  Secure encrypted storage for sensitive health data
//

import Foundation
import Security

class SecureHealthDataStore {
    static let shared = SecureHealthDataStore()
    private init() {}
    
    private let keychainService = "com.offleaf.healthdata"
    
    // MARK: - Secure Storage Operations
    
    func saveSecureData<T: Codable>(_ data: T, for key: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            
            // Delete any existing item
            deleteSecureData(for: key)
            
            // Create keychain query
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: key,
                kSecValueData as String: encodedData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        } catch {
            print("Failed to encode data for key \(key): \(error)")
            return false
        }
    }
    
    func loadSecureData<T: Codable>(_ type: T.Type, for key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("Failed to decode data for key \(key): \(error)")
            return nil
        }
    }
    
    func deleteSecureData(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    func deleteAllSecureData() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Migration from UserDefaults
    
    func migrateFromUserDefaults() {
        // Migrate daily check-in entries
        if let data = UserDefaults.standard.data(forKey: "dailyCheckInEntries"),
           let entries = try? JSONDecoder().decode([DailyCheckInEntry].self, from: data) {
            if saveSecureData(entries, for: "dailyCheckInEntries") {
                UserDefaults.standard.removeObject(forKey: "dailyCheckInEntries")
            }
        }
        
        // Migrate trigger plans
        if let triggers = UserDefaults.standard.array(forKey: "userTriggerPlans") as? [[String: String]] {
            if saveSecureData(triggers, for: "userTriggerPlans") {
                UserDefaults.standard.removeObject(forKey: "userTriggerPlans")
            }
        }
        
        // Migrate quit reasons
        if let reasons = UserDefaults.standard.array(forKey: "userQuitReasons") as? [String] {
            if saveSecureData(reasons, for: "userQuitReasons") {
                UserDefaults.standard.removeObject(forKey: "userQuitReasons")
            }
        }
        
        // Migrate assessment data - using individual keys since mixed types
        let assessmentKeys = [
            "assessmentPrimaryUseReason",
            "assessmentTimeSpentObtaining",
            "assessmentStrongCravings",
            "assessmentLostInterest",
            "assessmentConcernedLovedOnes",
            "assessmentFeelsGuilty",
            "assessmentToleranceIncrease",
            "assessmentQuitReadinessLevel",
            "assessmentQuitConfidenceLevel",
            "assessmentMotivationArea"
        ]
        
        // Migrate each assessment item individually to preserve type safety
        for key in assessmentKeys {
            if let stringValue = UserDefaults.standard.string(forKey: key) {
                if saveSecureData(stringValue, for: key) {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            } else if let intValue = UserDefaults.standard.object(forKey: key) as? Int {
                if saveSecureData(intValue, for: key) {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            } else if let boolValue = UserDefaults.standard.object(forKey: key) as? Bool {
                if saveSecureData(boolValue, for: key) {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
        }
        
        UserDefaults.standard.set(true, forKey: "healthDataMigrated")
    }
}

// MARK: - Secure Daily Check-In Store

extension DailyCheckInStore {
    static func loadEntriesSecure() -> [DailyCheckInEntry] {
        // Try to load from secure storage first
        if let entries = SecureHealthDataStore.shared.loadSecureData([DailyCheckInEntry].self, for: "dailyCheckInEntries") {
            return entries
        }
        
        // Fallback to UserDefaults and migrate if needed
        let entries = loadEntries()
        if !entries.isEmpty {
            _ = SecureHealthDataStore.shared.saveSecureData(entries, for: "dailyCheckInEntries")
            UserDefaults.standard.removeObject(forKey: "dailyCheckInEntries")
        }
        return entries
    }
    
    static func saveEntriesSecure(_ entries: [DailyCheckInEntry]) {
        _ = SecureHealthDataStore.shared.saveSecureData(entries, for: "dailyCheckInEntries")
    }
}