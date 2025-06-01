//
//  getPriceRulesUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Combine

protocol FetchAllDiscountCodesUseCaseProtocol {
    func execute() -> AnyPublisher<[PriceRule], Error>
}

class FetchAllDiscountCodesUseCase: FetchAllDiscountCodesUseCaseProtocol {
    private let repository: DiscountCodeRepositoryProtocol

    init(repository: DiscountCodeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[PriceRule], Error> {
        repository.fetchAllDiscountCodes()
    }
}
