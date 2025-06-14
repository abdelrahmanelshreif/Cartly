//
//  CalculateOrderSummaryUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation

final class CalculateOrderSummaryUseCase {
    func execute(for items: [ItemsMapper], discount: Double) -> OrderSummary {
        let subtotal = items.reduce(0) {
            guard let price = Double($1.price) else { return $0 }
            return $0 + (price * Double($1.quantity))
        }
        return OrderSummary(subtotal: subtotal, tax: 0, discount: discount)
    }
}
