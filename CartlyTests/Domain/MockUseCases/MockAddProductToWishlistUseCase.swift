//
//  MockAddProductToWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import XCTest
import Combine
@testable import Cartly

class MockAddProductToWishlistUseCase: AddProductToWishlistUseCaseProtocol {
    var publisher = PassthroughSubject<Void, Error>()
    var executeWasCalled = false
    func execute(userId: String, product: WishlistProduct) -> AnyPublisher<Void, Error> {
        executeWasCalled = true
        return publisher.eraseToAnyPublisher()
    }
}
