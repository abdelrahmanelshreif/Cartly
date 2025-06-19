//
//  MockNetwrokService.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 19/6/25.
//

import XCTest
import Combine
@testable import Cartly

// MARK: - Mock Network Service
class MockNetworkService: NetworkServiceProtocol {
    var requestCalled = false
    var requestParameters: APIRequest?
    var mockResponse: Any?
    var mockError: Error?
    
    func request<T>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T?, Error> where T : Decodable {
        requestCalled = true
        requestParameters = request
        
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
