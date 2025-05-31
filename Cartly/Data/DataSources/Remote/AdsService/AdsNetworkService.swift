//
//  AdsNetworkService.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine

protocol AdsNetworkServiceProtocol {
    func fetchPriceRules() -> AnyPublisher<[PriceRuleResponse], Error>
}

class AdsNetworkService: AdsNetworkServiceProtocol {
    func fetchPriceRules() -> AnyPublisher<[PriceRuleResponse], Error> {
        let url = URL(string: "https://683b1ce243bb370a8674c5d2.mockapi.io/adsImageData")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [PriceRuleResponse].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
