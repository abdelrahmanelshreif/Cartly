//
//  MockFirebaseShopifyLoginUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import Combine
import XCTest
@testable import Cartly

// MARK: - Mocks for FirebaseShopifyLoginUseCase
class MockFirebaseShopifyLoginUseCase: FirebaseShopifyLoginUseCaseProtocol {
    
    var publisher = PassthroughSubject<CustomerResponse, Error>()
    var executeWasCalled = false
    var receivedCredentials: EmailCredentials?
    
    func execute(credentials: EmailCredentials) -> AnyPublisher<CustomerResponse, Error> {
        print("[MockLoginUseCase] execute called with email: \(credentials.email)")
    
        executeWasCalled = true
        receivedCredentials = credentials
        
        return publisher.eraseToAnyPublisher()
    }
    
    func sendSuccess(customer: Customer) {
        let response = CustomerResponse(customer: customer)
        publisher.send(response)
        publisher.send(completion: .finished)
    }
    
    func sendFailure(error: Error) {
        publisher.send(completion: .failure(error))
    }
}
