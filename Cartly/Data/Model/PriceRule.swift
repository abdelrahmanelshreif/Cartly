//
//  PriceRule.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//
import Foundation

import Foundation

struct PriceRuleResponse: Codable {
    let price_rule: PriceRule
}

struct PriceRule: Codable, Identifiable {
    //Required By Identifiable
    var id: UUID { UUID() } 
    let title: String
    let target_type: String
    let target_selection: String
    let allocation_method: String
    let value_type: String
    let value: String
    let customer_selection: String
    let usage_limit: Int?
    let allocation_limit: Int?
    let starts_at: String
    let image_url: String
}
