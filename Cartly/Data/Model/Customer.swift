import Foundation

struct CustomerResponse: Codable {
    let customer: Customer
}

// MARK: - Customer Model
struct Customer: Codable {
    let id: Int64 
    let email: String
    let createdAt: String
    let updatedAt: String
    let firstName: String
    let lastName: String
    let ordersCount: Int
    let state: String /// when ordering if verified will invited if not will be disabled.
    let totalSpent: String
    let lastOrderId: Int?
    let note: String?
    let verifiedEmail: Bool
    let multipassIdentifier: String?
    let taxExempt: Bool
    let tags: String /// Password
    let lastOrderName: String?
    let currency: String
    let phone: String
    let addresses: [Address]
    let emailMarketingConsent: MarketingConsent
    let smsMarketingConsent: SMSMarketingConsent
    let adminGraphqlApiId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case firstName = "first_name"
        case lastName = "last_name"
        case ordersCount = "orders_count"
        case state
        case totalSpent = "total_spent"
        case lastOrderId = "last_order_id"
        case note
        case verifiedEmail = "verified_email"
        case multipassIdentifier = "multipass_identifier"
        case taxExempt = "tax_exempt"
        case tags
        case lastOrderName = "last_order_name"
        case currency
        case phone
        case addresses
        case emailMarketingConsent = "email_marketing_consent"
        case smsMarketingConsent = "sms_marketing_consent"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

// MARK: - Marketing Consent Model
struct MarketingConsent: Codable {
    let state: String
    let optInLevel: String
    let consentUpdatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case state
        case optInLevel = "opt_in_level"
        case consentUpdatedAt = "consent_updated_at"
    }
}

// MARK: - SMS Marketing Consent Model
struct SMSMarketingConsent: Codable {
    let state: String
    let optInLevel: String
    let consentUpdatedAt: String?
    let consentCollectedFrom: String
    
    enum CodingKeys: String, CodingKey {
        case state
        case optInLevel = "opt_in_level"
        case consentUpdatedAt = "consent_updated_at"
        case consentCollectedFrom = "consent_collected_from"
    }
}
