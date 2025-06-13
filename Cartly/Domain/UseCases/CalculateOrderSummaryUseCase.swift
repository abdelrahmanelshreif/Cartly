//
//  CalculateOrderSummaryUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation

final class CalculateOrderSummaryUseCase {
    func execute(for cartItems: [CartItem], discount: Double) -> OrderSummary {
        let subtotal = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return OrderSummary(subtotal: subtotal, tax: 0, discount: discount)
    }
}
