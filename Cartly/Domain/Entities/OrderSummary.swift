//
//  OrderSummary.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation
struct OrderSummary {
    let subtotal: Double
    let tax: Double
    let discount: Double
    var total: Double {
        subtotal + tax - discount
    }
}
