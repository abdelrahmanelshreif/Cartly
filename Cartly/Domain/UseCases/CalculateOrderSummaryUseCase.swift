//
//  CalculateOrderSummaryUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation

final class CalculateOrderSummaryUseCase {
    func execute(for cartItems: [CartItem], discount: Double, taxRate: Double) -> OrderSummary {
        let subtotal = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        let tax = subtotal * taxRate
        return OrderSummary(subtotal: subtotal, tax: tax, discount: discount)
    }
}
