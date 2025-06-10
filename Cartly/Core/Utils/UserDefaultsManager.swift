//
//  UserDefaults.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.
//

import Foundation

struct UserDefaultsManager {
    private static let userDefaults = Foundation.UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let customerID = "customer_id"
        static let isLoggedIn = "is_logged_in"
    }
    
    // MARK: - Customer ID
    static func saveCustomerID(_ id: String) {
        userDefaults.set(id, forKey: Keys.customerID)
    }
    
    static func getCustomerID() -> String? {
        return userDefaults.string(forKey: Keys.customerID)
    }
    
    static func removeCustomerID() {
        userDefaults.removeObject(forKey: Keys.customerID)
    }
    
    // MARK: - Login Status
    static func saveLoginStatus(_ isLoggedIn: Bool) {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
    }
    
    static func getLoginStatus() -> Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    static func removeLoginStatus() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
    }
    
    // MARK: - Clear All User Data
    static func clearAllUserData() {
        removeCustomerID()
        removeLoginStatus()
    }
}
