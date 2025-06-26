//
//  MockSearchProductAtWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//


import XCTest
import Combine
@testable import Cartly


class MockSearchProductAtWishlistUseCase: SearchProductAtWishlistUseCaseProtocol {
    var publisher = PassthroughSubject<Bool, Error>()
    func execute(userId: String, productId: String) -> AnyPublisher<Bool, Error> { publisher.eraseToAnyPublisher() }
}
