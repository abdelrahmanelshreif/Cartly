//
//  Untitled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import Combine
import XCTest
@testable import Cartly

class MockAuthenticatingUserWithGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol {
    
    var publisher = PassthroughSubject<CustomerResponse, Error>()
        var executeWasCalled = false
    
    func execute() -> AnyPublisher<CustomerResponse, Error> {
        print("[MockGoogleLoginUseCase] execute called")
        executeWasCalled = true
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
