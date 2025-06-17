import Foundation

/// DraftOrdersResponse
struct DraftOrdersResponse: Codable {
    let draftOrders: [DraftOrder]?

    enum CodingKeys: String, CodingKey {
        case draftOrders = "draft_orders"
    }
}

struct DraftOrderResponse: Codable {
    let draftOrder: DraftOrder?
    
    enum CodingKeys: String, CodingKey {
        case draftOrder = "draft_order"
    }
}

/// Represents a Draft Order in Shopify
struct DraftOrder: Codable {
    /// Unique identifier for the draft order
    var id: Int64?
    var note: String?
    /// Customer's email for the order
    var email: String?
    var taxesIncluded: Bool?
    /// Currency used for the draft order
    var currency: String?
    var invoiceSentAt: String?
    var createdAt: String?
    var updatedAt: String?
    var taxExempt: Bool?
    var completedAt: String?
    /// Name or identifier for the draft order
    var name: String?
    var allowDiscountCodesInCheckout: Bool?
    var b2b: Bool?
    /// Current status of the draft order (open, closed, etc.) VERY IMPORTANT
    var status: String?
    /// Array of line items in the draft order
    var lineItems: [LineItem]?
    var apiClientId: Int64?
    var shippingAddress: ShopifyAddress?
    var billingAddress: String?
    var invoiceUrl: String?
    var createdOnApiVersionHandle: String?
    var appliedDiscount: AppliedDiscount?
    /// Order identifier VERY IMPORTANT
    var orderId: Int64?
    var shippingLine: String?
    /// Tax details for the draft order
    var taxLines: [TaxLine]?
    var tags: String?
    var noteAttributes: [String]?
    /// Total price of the draft order (including taxes)
    var totalPrice: String?
    /// Subtotal price of the draft order (excluding taxes)
    var subtotalPrice: String?
    /// Total tax amount for the draft order
    var totalTax: String?
    var paymentTerms: String?
    var adminGraphqlApiId: String?
    var customer: Customer?

    enum CodingKeys: String, CodingKey {
        case id, note, email, currency, status, name, tags, customer
        case taxesIncluded = "taxes_included"
        case invoiceSentAt = "invoice_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxExempt = "tax_exempt"
        case completedAt = "completed_at"
        case allowDiscountCodesInCheckout = "allow_discount_codes_in_checkout?"
        case b2b = "b2b?"
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
        case noteAttributes = "note_attributes"
        case totalPrice = "total_price"
        case subtotalPrice = "subtotal_price"
        case totalTax = "total_tax"
        case paymentTerms = "payment_terms"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

/// Represents a line item in the draft order
struct LineItem: Codable {
    /// Unique identifier for the line item
    var id: Int64?
    var variantId: Int64?
    var productId: Int64?
    var title: String?
    var variantTitle: String?
    /// SKU (stock keeping unit) for the product (optional)
    var sku: String?
    var vendor: String?
    /// Quantity of the item being purchased
    var quantity: Int?
    var requiresShipping: Bool?
    /// Indicates whether the item is taxable
    var taxable: Bool?
    var giftCard: Bool?
    var fulfillmentService: String?
    var grams: Int?
    /// Tax lines applicable to the line item
    var taxLines: [TaxLine]?
    var appliedDiscount: AppliedDiscount?
    /// Name of the product
    var name: String?
    var properties: [String]?
    var custom: Bool?
    /// Price of the product
    var price: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, sku, vendor, quantity, grams, custom, price, name, properties, taxable
        case variantId = "variant_id"
        case productId = "product_id"
        case variantTitle = "variant_title"
        case requiresShipping = "requires_shipping"
        case giftCard = "gift_card"
        case fulfillmentService = "fulfillment_service"
        case taxLines = "tax_lines"
        case appliedDiscount = "applied_discount"
    }
}

struct AppliedDiscount: Codable {
    /// Description of the discount
    var description: String?
    /// Value of the discount (percentage or fixed amount)
    var value: String?
    /// Title of the discount
    var title: String?
    /// Amount of the discount applied
    var amount: String?
    /// Type of the discount (percentage or fixed amount)
    var valueType: String?
    
    enum CodingKeys: String, CodingKey {
        case description, value, title, amount
        case valueType = "value_type"
    }
}

/// Represents tax details for an order or line item
struct TaxLine: Codable {
    var rate: Double?
    var title: String?
    var price: String?
    
    enum CodingKeys: String, CodingKey {
        case rate, title, price
    }
}
struct ShopifyAddress: Codable {
    var firstName: String?
    var lastName: String?
    var address1: String?
    var address2: String?
    var phone: String?
    var city: String?
    var province: String?
    var country: String?
    var zip: String?
    var latitude: Double?
    var longitude: Double?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1, address2, phone, city, province, country, zip, latitude, longitude
    }
}



