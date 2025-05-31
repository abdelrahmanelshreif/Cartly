//
//  AdsRepository.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine

class PriceRuleRepository: PriceRuleRepositoryProtocol {
    private let networkService: AdsNetworkServiceProtocol
    
    init(networkService: AdsNetworkServiceProtocol = AdsNetworkService()) {
        self.networkService = networkService
    }
    
    func getPriceRules() -> AnyPublisher<[PriceRule], Error> {
        return networkService.fetchPriceRules()
            .map { responses in
                responses.map { $0.price_rule }
            }
            .eraseToAnyPublisher()
    }
}
