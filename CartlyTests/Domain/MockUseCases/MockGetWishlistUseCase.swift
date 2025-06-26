//
//  Untitled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//


import XCTest
import Combine
@testable import Cartly


class MockGetWishlistUseCase: GetWishlistUseCaseProtocol {
    var publisher = PassthroughSubject<[WishlistProduct]?, Error>()
    func execute(userId: String) -> AnyPublisher<[WishlistProduct]?, Error> { publisher.eraseToAnyPublisher() }
}
