//
//  KeychainHelper.swift
//  Offleaf
//

import Foundation
import Security
import CryptoKit

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private let service: String = Bundle.main.bundleIdentifier ?? "io.Offleaf"
    private let passcodeKey = "userPasscodeHash"
    private let saltKey = "userPasscodeSalt"
    
    // Hash passcode with salt before storing
    func savePasscode(_ passcode: String) -> Bool {
        // Generate a random salt for this passcode
        let salt = generateSalt()
        
        // Hash the passcode with the salt
        guard let hashedData = hashPasscode(passcode, salt: salt) else { return false }
        
        // Delete any existing passcode first
        _ = deletePasscode()
        
        // Save the salt
        let saltQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: saltKey,
            kSecValueData as String: salt,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        _ = SecItemAdd(saltQuery as CFDictionary, nil)
        
        // Save the hashed passcode
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passcodeKey,
            kSecValueData as String: hashedData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Verify passcode by hashing input and comparing
    func verifyPasscode(_ passcode: String) -> Bool {
        // Get the stored salt
        guard let salt = getSalt() else { return false }
        
        // Get the stored hash
        guard let storedHash = getStoredHash() else { return false }
        
        // Hash the input passcode with the same salt
        guard let inputHash = hashPasscode(passcode, salt: salt) else { return false }
        
        // Use constant-time comparison to prevent timing attacks
        return constantTimeCompare(storedHash, inputHash)
    }
    
    // Constant-time comparison to prevent timing attacks
    private func constantTimeCompare(_ data1: Data, _ data2: Data) -> Bool {
        // Compare lengths first
        guard data1.count == data2.count else { return false }
        
        // XOR all bytes and accumulate differences
        // This ensures all bytes are compared regardless of differences
        var result: UInt8 = 0
        for i in 0..<data1.count {
            result |= data1[i] ^ data2[i]
        }
        
        // Result is 0 only if all bytes matched
        return result == 0
    }
    
    // Legacy method - now returns nil for security
    func getPasscode() -> String? {
        // This method should no longer be used - passcodes cannot be retrieved
        // Use verifyPasscode instead
        return nil
    }
    
    private func hashPasscode(_ passcode: String, salt: Data) -> Data? {
        guard let passcodeData = passcode.data(using: .utf8) else { return nil }
        let saltedData = passcodeData + salt
        let hashed = SHA256.hash(data: saltedData)
        return Data(hashed)
    }
    
    private func generateSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }
    
    private func getSalt() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: saltKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    private func getStoredHash() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passcodeKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    func deletePasscode() -> Bool {
        // Delete the hash
        let hashQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passcodeKey
        ]
        let hashStatus = SecItemDelete(hashQuery as CFDictionary)
        
        // Delete the salt
        let saltQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: saltKey
        ]
        let saltStatus = SecItemDelete(saltQuery as CFDictionary)
        
        return (hashStatus == errSecSuccess || hashStatus == errSecItemNotFound) &&
               (saltStatus == errSecSuccess || saltStatus == errSecItemNotFound)
    }
    
    func hasPasscode() -> Bool {
        return getStoredHash() != nil
    }
}