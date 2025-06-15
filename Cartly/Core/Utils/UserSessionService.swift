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
    func getCurrentUserEmail() -> String?
    func isUserLoggedIn() -> Bool?
    func isUserEmailVerified() -> Bool?
    func getCurrentUserName() -> String?
    func setVerificationStatus(_ status:Bool)
}

// MARK: - User Session Implementation
class UserSessionService: UserSessionServiceProtocol {
  
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let userId = "user_id"
        static let userEmail = "user_email"
        static let userName = "user_name"
        static let isLoggedIn = "is_logged_in"
        static let isUserVerified = "is_verified"
    }
    
    func saveUserSession(_ customer: Customer) {
        userDefaults.set(customer.id, forKey: Keys.userId)
        userDefaults.set(customer.email, forKey: Keys.userEmail)
        userDefaults.set((customer.firstName ?? "") + " " + (customer.lastName ?? ""), forKey: Keys.userName)
        userDefaults.set(true, forKey: Keys.isLoggedIn)
    }
    
    func setVerificationStatus(_ status:Bool){
        userDefaults.set(status, forKey: Keys.isUserVerified)
    }
    
    func clearUserSession() {
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userEmail)
        userDefaults.removeObject(forKey: Keys.userName)
        userDefaults.removeObject(forKey: Keys.isUserVerified)
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.isUserVerified)
    }
    
    func getCurrentUserId() -> String? {
        return userDefaults.string(forKey: Keys.userId)
    }
    
    func getCurrentUserEmail() -> String? {
        return userDefaults.string(forKey: Keys.userEmail)
    }
        
    func getCurrentUserName() -> String? {
        return userDefaults.string(forKey: Keys.userName) ?? "Cartly User"
    }
    
    func isUserLoggedIn() -> Bool? {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    func isUserEmailVerified() -> Bool? {
        return userDefaults.bool(forKey: Keys.isUserVerified)

    }
}
