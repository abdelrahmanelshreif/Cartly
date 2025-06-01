//
//  PriceRule.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//
import Foundation

struct PriceRuleResponse: Codable {
    let priceRules: [PriceRule]

    enum CodingKeys: String, CodingKey {
        case priceRules = "price_rules"
    }
}

struct PriceRule: Codable, Identifiable {
    let id: Int64
    let title: String?
    var discountCodes: [DiscountCode]?
    var adImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
    }
}

struct DiscountCodeResponse: Codable {
    let discountCodes: [DiscountCode]

    enum CodingKeys: String, CodingKey {
        case discountCodes = "discount_codes"
    }
}

struct DiscountCode: Codable, Identifiable {
    let id: Int64
    let code: String
    let priceRuleId: Int64

    enum CodingKeys: String, CodingKey {
        case id, code
        case priceRuleId = "price_rule_id"
    }
}

struct AdImage: Codable {
    let image_url: String
}
