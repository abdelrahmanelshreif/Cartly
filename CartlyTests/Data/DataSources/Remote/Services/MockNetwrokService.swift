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
    let responseSubject = PassthroughSubject<Any, Error>()
    
    func request<T>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T?, Error> where T : Decodable {
        requestCalled = true
        requestParameters = request
        
        return responseSubject
            .tryMap { response in
                return response as? T
            }
            .eraseToAnyPublisher()
    }
}
