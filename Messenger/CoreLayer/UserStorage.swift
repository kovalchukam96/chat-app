import UIKit
import Security

protocol UserStorage {
    func getValue(for key: String) -> String?
    func setValue(value: String, for key: String)
}

final class UserStorageImpl: UserStorage {
    
    func getValue(for key: String) -> String? {
        var result: AnyObject?
      
        let kCFBooleanTrueValue = kCFBooleanTrue as Any as AnyObject
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrueValue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        
        guard let data = result as? Data else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func setValue(value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecAttrAccount as String: key
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        }
    }
}
