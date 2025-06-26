//
//  MockAddToCartUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import XCTest
import Combine
@testable import Cartly


class MockAddToCartUseCase: AddToCartUseCaseProtocol {
    var publisher = PassthroughSubject<CustomSuccess, Error>()
    var executeWasCalled = false
    var receivedCartEntity: CartEntity?

    func execute(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error> {
        executeWasCalled = true
        receivedCartEntity = cartEntity
        return publisher.eraseToAnyPublisher()
    }
}
