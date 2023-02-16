//
//  KeychainInterface.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import Foundation
import Security

final class KeychainInterface {
    /// Save item to the keychain
    static func save(key: String, value: String) -> OSStatus {
        // Convert value to data
        let valueData = value.data(using: .utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData as Any
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status
    }
    
    /// Retrieve item from the keychain
    static func retrieve(key:String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        var item: AnyObject?
        
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            guard let existingItem = item as? [String: Any],
                  let tokenData = existingItem[kSecValueData as String] as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else { return nil}
            
            return token
        } else {
            return nil
        }
    }
    
    /// Delete item from the keychain
    static func delete(key:String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        
        if SecItemDelete(query as CFDictionary) == noErr {
            return true
        } else {
            return false
        }
    }
}
