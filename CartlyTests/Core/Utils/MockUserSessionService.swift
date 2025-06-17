//
//  MockUserSessionService.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 16/6/25.
//

import Foundation
@testable import Cartly

final class MockUserSessionService: UserSessionServiceProtocol {
    
    // MARK: - Spy Properties
    var saveUserSessionCallCount = 0
    var lastSavedCustomer: Customer?
    
    var clearUserSessionCallCount = 0
    
    // MARK: - Stubbed Return Values
    var currentUserIdToReturn: String?
    var currentUserEmailToReturn: String?
    var currentUserVerificationStatusToReturn: String?
    var isUserLoggedInToReturn: Bool = false
    var isUserEmailVerifiedToReturn: Bool = false
    var currentUserNameToReturn: String?
    
    // MARK: - Protocol Conformance
    func saveUserSession(_ customer: Customer) {
        saveUserSessionCallCount += 1
        lastSavedCustomer = customer
    }
    
    func clearUserSession() {
        clearUserSessionCallCount += 1
    }
    
    func getCurrentUserId() -> String? {
        return currentUserIdToReturn
    }
    
    func getCurrentUserVerificationStatus() -> String? {
        return currentUserVerificationStatusToReturn
    }
    
    func getCurrentUserEmail() -> String? {
        return currentUserEmailToReturn
    }
    
    func isUserLoggedIn() -> Bool? {
        return isUserLoggedInToReturn
    }
    
    func isUserEmailVerified() -> Bool? {
        return isUserEmailVerifiedToReturn
    }
    
    func getCurrentUserName() -> String? {
        return currentUserNameToReturn
    }
}
