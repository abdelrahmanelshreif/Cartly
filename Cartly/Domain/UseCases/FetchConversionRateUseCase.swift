//
//  FetchConversionRateUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation
import Combine

protocol ConvertCurrencyUseCaseProtocol {
    func execute(from: String, to: String) -> AnyPublisher<Double, Error>
}

final class ConvertCurrencyUseCase: ConvertCurrencyUseCaseProtocol {
    private let repository: CurrencyRepositoryProtocol

    init(repository: CurrencyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(from: String, to: String) -> AnyPublisher<Double, Error> {
        repository.getExchangeRate(from: from, to: to)
    }
}
