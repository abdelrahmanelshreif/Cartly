//
//  MockConvertCurrencyUseCase.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//

import Combine
@testable import Cartly
import Foundation

final class MockConvertCurrencyUseCase: ConvertCurrencyUseCaseProtocol {
    var result: Result<Double, Error>

    init(result: Result<Double, Error>) {
        self.result = result
    }

    func execute(from: String, to: String) -> AnyPublisher<Double, Error> {
        result.publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
