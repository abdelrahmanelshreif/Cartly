//
//  OrderDTO.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 17/6/25.
//

import Foundation

struct CustomerOrdersResponse: Codable {
    let orders: [Order]?

}

struct Order: Codable{
    let id: Int64?
    let adminGraphqlApiId: String?
    let confirmationNumber: String?
    let confirmed: Bool?
    let contactEmail: String?
    let createdAt: String?
    let currency: String?
    let currentSubtotalPrice: String?
    let currentTotalPrice: String?
    let currentTotalTax: String?
    let customerLocale: String?
    let email: String?
    let financialStatus: String?
    let fulfillmentStatus: String?
    let name: String?
    let orderNumber: Int?
    let orderStatusUrl: String?
    let paymentGatewayNames: [String]?
    let presentmentCurrency: String?
    let processedAt: String?
    let subtotalPrice: String?
    let totalPrice: String?
    let totalTax: String?
    let updatedAt: String?
    let lineItems: [LineItem]?
    let shippingAddress: Address?
    
    enum CodingKeys: String, CodingKey {
        case id
        case adminGraphqlApiId = "admin_graphql_api_id"
        case confirmationNumber = "confirmation_number"
        case confirmed
        case contactEmail = "contact_email"
        case createdAt = "created_at"
        case currency
        case currentSubtotalPrice = "current_subtotal_price"
        case currentTotalPrice = "current_total_price"
        case currentTotalTax = "current_total_tax"
        case customerLocale = "customer_locale"
        case email
        case financialStatus = "financial_status"
        case fulfillmentStatus = "fulfillment_status"
        case name
        case orderNumber = "order_number"
        case orderStatusUrl = "order_status_url"
        case paymentGatewayNames = "payment_gateway_names"
        case presentmentCurrency = "presentment_currency"
        case processedAt = "processed_at"
        case subtotalPrice = "subtotal_price"
        case totalPrice = "total_price"
        case totalTax = "total_tax"
        case updatedAt = "updated_at"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
    }
}
