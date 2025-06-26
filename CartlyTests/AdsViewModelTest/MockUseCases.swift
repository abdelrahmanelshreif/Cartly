//
//  MockUseCases.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//

import XCTest
import Combine
@testable import Cartly

class MockFetchAllDiscountCodesUseCase: FetchAllDiscountCodesUseCaseProtocol {
    var result: Result<[PriceRule], Error>

    init(result: Result<[PriceRule], Error>) {
        self.result = result
    }

    func execute() -> AnyPublisher<[PriceRule], Error> {
        return result.publisher
            .eraseToAnyPublisher()
    }
}
