//
//  MockShopifyServices.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 16/6/25.
//

import Foundation
import Combine
import XCTest
@testable import Cartly

// MARK: - Mock ShopifyServices
class MockShopifyServices: ShopifyServicesProtocol {
    var signupCallCount = 0
    var lastSignUpData: SignUpData?
    
    let signupSubject = PassthroughSubject<CustomerResponse?, Error>()
    
    func signup(userData: SignUpData) -> AnyPublisher<CustomerResponse?, Error> {
        signupCallCount += 1
        lastSignUpData = userData
        
        return signupSubject.eraseToAnyPublisher()
    }
}
