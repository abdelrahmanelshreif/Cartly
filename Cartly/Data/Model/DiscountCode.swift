//
//  PriceRule.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//
import Foundation

struct PriceRuleResponse: Codable, Equatable {
    let priceRules: [PriceRule]
    
    enum CodingKeys: String, CodingKey {
        case priceRules = "price_rules"
    }
}

struct PriceRule: Codable, Identifiable, Equatable {
    let id: Int64
    let title: String?
    let valueType: String
    let value: String
    let prerequisiteSubtotalRange: SubtotalRange?
    let usageLimit: Int?
    var discountCodes: [DiscountCode]?
    var adImageUrl: String?
    let prerequisiteToEntitlementQuantityRatio: QuantityRatio?
    let prerequisiteToEntitlementPurchase: PurchaseCondition?
    
    struct SubtotalRange: Codable, Equatable {
        let greaterThanOrEqualTo: String
        
        enum CodingKeys: String, CodingKey {
            case greaterThanOrEqualTo = "greater_than_or_equal_to"
        }
    }
    
    struct QuantityRatio: Codable, Equatable {
        let prerequisiteQuantity: Int?
        let entitledQuantity: Int?
        
        enum CodingKeys: String, CodingKey {
            case prerequisiteQuantity = "prerequisite_quantity"
            case entitledQuantity = "entitled_quantity"
        }
    }
    
    struct PurchaseCondition: Codable, Equatable {
        let prerequisiteAmount: Double?
        
        enum CodingKeys: String, CodingKey {
            case prerequisiteAmount = "prerequisite_amount"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, value, discountCodes, adImageUrl
        case valueType = "value_type"
        case usageLimit = "usage_limit"
        case prerequisiteSubtotalRange = "prerequisite_subtotal_range"
        case prerequisiteToEntitlementQuantityRatio = "prerequisite_to_entitlement_quantity_ratio"
        case prerequisiteToEntitlementPurchase = "prerequisite_to_entitlement_purchase"
    }
}


struct DiscountCodeResponse: Codable, Equatable {
    let discountCodes: [DiscountCode]
    
    enum CodingKeys: String, CodingKey {
        case discountCodes = "discount_codes"
    }
}

struct DiscountCode: Codable, Identifiable, Equatable {
    let id: Int64
    let code: String
    let priceRuleId: Int64
    let usageCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, code, usageCount = "usage_count"
        case priceRuleId = "price_rule_id"
    }
}

struct AdImage: Codable, Equatable {
    let image_url: String
}
