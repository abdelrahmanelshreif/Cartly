//
//  getPriceRulesUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine

protocol GetPriceRulesUseCaseProtocol {
    func execute() -> AnyPublisher<[PriceRule], Error>
}

class GetPriceRulesUseCase: GetPriceRulesUseCaseProtocol {
    private let repository: PriceRuleRepositoryProtocol
    
    init(repository: PriceRuleRepositoryProtocol = PriceRuleRepository()) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[PriceRule], Error> {
        return repository.getPriceRules()
    }
}
