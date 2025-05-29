//
//  Cart.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//

import Foundation

// MARK: - Root Response Model
struct DraftOrderResponse: Codable {
    let draftOrder: DraftOrder
    
    enum CodingKeys: String, CodingKey {
        case draftOrder = "draft_order"
    }
}

// MARK: - Draft Order Model (Cart)
struct DraftOrder: Codable {
    let id: Int64
    let note: String?
    let email: String?
    let taxesIncluded: Bool
    let currency: String
    let invoiceSentAt: String?
    let createdAt: String
    let updatedAt: String
    let taxExempt: Bool
    let completedAt: String?
    let name: String?
    let allowDiscountCodesInCheckout: Bool?
    let b2b: Bool?
    let status: String?
    let lineItems: [LineItem]?
    let apiClientId: Int64?
    let shippingAddress: Address?
    let billingAddress: Address?
    let invoiceUrl: String?
    let createdOnApiVersionHandle: String?
    let appliedDiscount: AppliedDiscount?
    let orderId: Int64?
    let shippingLine: ShippingLine?
    let taxLines: [TaxLine]?
    let tags: String?
    let noteAttributes: [NoteAttribute]?
    let totalPrice: String?
    let subtotalPrice: String?
    let totalTax: String?
    let adminGraphqlApiId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case note
        case email
        case taxesIncluded = "taxes_included"
        case currency
        case invoiceSentAt = "invoice_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxExempt = "tax_exempt"
        case completedAt = "completed_at"
        case name
        case allowDiscountCodesInCheckout = "allow_discount_codes_in_checkout?"
        case b2b = "b2b?"
        case status
        case lineItems = "line_items"
        case apiClientId = "api_client_id"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case invoiceUrl = "invoice_url"
        case createdOnApiVersionHandle = "created_on_api_version_handle"
        case appliedDiscount = "applied_discount"
        case orderId = "order_id"
        case shippingLine = "shipping_line"
        case taxLines = "tax_lines"
        case tags
        case noteAttributes = "note_attributes"
        case totalPrice = "total_price"
        case subtotalPrice = "subtotal_price"
        case totalTax = "total_tax"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

// MARK: - Line Item Model
struct LineItem: Codable {
    let id: Int64
    let variantId: Int64?
    let productId: Int64?
    let title: String
    let variantTitle: String?
    let sku: String?
    let vendor: String?
    let quantity: Int
    let requiresShipping: Bool
    let taxable: Bool
    let giftCard: Bool
    let fulfillmentService: String
    let grams: Int
    let taxLines: [TaxLine]
    let appliedDiscount: AppliedDiscount?
    let name: String
    let properties: [LineItemProperty]
    let custom: Bool
    let price: String
    let adminGraphqlApiId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case variantId = "variant_id"
        case productId = "product_id"
        case title
        case variantTitle = "variant_title"
        case sku
        case vendor
        case quantity
        case requiresShipping = "requires_shipping"
        case taxable
        case giftCard = "gift_card"
        case fulfillmentService = "fulfillment_service"
        case grams
        case taxLines = "tax_lines"
        case appliedDiscount = "applied_discount"
        case name
        case properties
        case custom
        case price
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

// MARK: - Applied Discount Model
struct AppliedDiscount: Codable {
    let description: String
    let value: String
    let title: String
    let amount: String
    let valueType: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case value
        case title
        case amount
        case valueType = "value_type"
    }
}

// MARK: - Tax Line Model
struct TaxLine: Codable {
    let rate: Double
    let title: String
    let price: String
}

// MARK: - Line Item Property Model
struct LineItemProperty: Codable {
    let name: String
    let value: String
}

// MARK: - Shipping Line Model
struct ShippingLine: Codable {
    let title: String?
    let custom: Bool?
    let handle: String?
    let price: String?
}

// MARK: - Note Attribute Model
struct NoteAttribute: Codable {
    let name: String
    let value: String
}
