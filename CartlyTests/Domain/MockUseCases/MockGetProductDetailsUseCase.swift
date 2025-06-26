//
//  MockGetProductDetailsUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import XCTest
import Combine
@testable import Cartly

// MARK: - Mock Dependencies
class MockGetProductDetailsUseCase: GetProductDetailsUseCaseProtocol {
    var publisher = PassthroughSubject<Result<Product?, Error>, Never>()

    func execute(productId: Int64) -> AnyPublisher<Result<Product?, Error>, Never> {
        return publisher.eraseToAnyPublisher()
    }
}
