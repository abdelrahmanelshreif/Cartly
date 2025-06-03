//
//  UserSessionService.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//

import Foundation

// MARK: - User Session Protocol
protocol UserSessionServiceProtocol {
    func saveUserSession(_ customer: Customer)
    func clearUserSession()
    func getCurrentUserId() -> String?
    func isUserLoggedIn() -> Bool
}

// MARK: - User Session Implementation
class UserSessionService: UserSessionServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let userId = "user_id"
        static let userEmail = "user_email"
        static let userName = "user_name"
        static let isLoggedIn = "is_logged_in"
    }
    
    func saveUserSession(_ customer: Customer) {
        userDefaults.set(customer.id, forKey: Keys.userId)
        userDefaults.set(customer.email, forKey: Keys.userEmail)
        userDefaults.set(customer.firstName + " " + customer.lastName, forKey: Keys.userName)
        userDefaults.set(true, forKey: Keys.isLoggedIn)
    }
    
    func clearUserSession() {
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userEmail)
        userDefaults.removeObject(forKey: Keys.userName)
        userDefaults.set(false, forKey: Keys.isLoggedIn)
    }
    
    func getCurrentUserId() -> String? {
        return userDefaults.string(forKey: Keys.userId)
    }
    
    func isUserLoggedIn() -> Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
}
