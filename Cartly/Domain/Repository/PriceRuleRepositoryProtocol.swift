//
//  PriceRuleRepositoryProtocol.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine
protocol PriceRuleRepositoryProtocol {
    func getPriceRules() -> AnyPublisher<[PriceRule], Error>
}
