//
//  MockGetProductsForBrandId.swift
//  CartlyTests
//
//  Created by Khaled Mustafa on 26/06/2025.
//

@testable import Cartly
import Combine
import Foundation

class MockGetProductsForBrandId: GetProductsForBrandId {
    var executeCalled = false
    var executeBrandId: Int64?
    var mockResult: Result<[ProductMapper], Error>?

    init() {
        super.init(repository: MockRepository())
    }

    override func execute(for brand_id: Int64) -> AnyPublisher<[ProductMapper], Error> {
        executeCalled = true
        executeBrandId = brand_id

        if let result = mockResult {
            switch result {
            case let .success(products):
                return Just(products)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case let .failure(error):
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }

        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
