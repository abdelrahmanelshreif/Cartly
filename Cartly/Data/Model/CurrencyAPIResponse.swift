//
//  CurrencyAPIResponse.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation

struct CurrencyRateResponse: Codable {
    let data: [String: CurrencyData]
}

struct CurrencyData: Codable {
    let value: Double
}
