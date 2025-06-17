//
//  MockShopifyServices.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 16/6/25.
//

import Foundation
import Combine
@testable import Cartly

final class MockShopifyServices: ShopifyServicesProtocol {
    
    // MARK: - Control Subjects
    let signupSubject = PassthroughSubject<CustomerResponse?, Error>()
    
    // MARK: - Spy Properties
    var signupCallCount = 0
    var lastSignUpData: SignUpData?
    
    // MARK: - Protocol Conformance
    func signup(userData: SignUpData) -> AnyPublisher<CustomerResponse?, Error> {
        signupCallCount += 1
        lastSignUpData = userData
        return signupSubject.eraseToAnyPublisher()
    }
}
