//
//  AdsRepository.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine

class DiscountCodeRepository: DiscountCodeRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let adsNetworkService: AdsNetworkServiceProtocol

    init(networkService: NetworkServiceProtocol, adsNetworkService: AdsNetworkServiceProtocol) {
        self.networkService = networkService
        self.adsNetworkService = adsNetworkService
    }

    func fetchAllDiscountCodes() -> AnyPublisher<[PriceRule], Error> {
        return adsNetworkService.fetchAdsImages()
            .flatMap { [weak self] adImages -> AnyPublisher<[PriceRule], Error> in
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }
                
                let priceRuleRequest = APIRequest(withPath: "/price_rules.json")
                return self.networkService.request(priceRuleRequest, responseType: PriceRuleResponse.self)
                    .tryMap { response -> [PriceRule] in
                        guard let priceRules = response?.priceRules else {
                            throw URLError(.badServerResponse)
                        }
                        return priceRules
                    }
                    .flatMap { priceRules -> AnyPublisher<[PriceRule], Error> in
                        let publishers = priceRules.map { rule in
                            let discountRequest = APIRequest(withPath: "/price_rules/\(rule.id)/discount_codes.json")
                            return self.networkService.request(discountRequest, responseType: DiscountCodeResponse.self)
                                .map { discountResponse -> PriceRule in
                                    var mutableRule = rule
                                    mutableRule.discountCodes = discountResponse?.discountCodes ?? []
                                    
                                    if let index = priceRules.firstIndex(where: { $0.id == rule.id }),
                                       index < adImages.count {
                                        mutableRule.adImageUrl = adImages[index].image_url
                                    }
                                    return mutableRule
                                }
                                .catch { error -> Just<PriceRule> in
                                    print("Failed to fetch discount codes for rule \(rule.id): \(error)")
                                    return Just(rule)
                                }
                                .eraseToAnyPublisher()
                        }
                        
                        return Publishers.MergeMany(publishers)
                            .collect()
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
