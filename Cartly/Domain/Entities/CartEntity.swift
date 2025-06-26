import Foundation

/// Represents a simplified cart entity
struct CartEntity: Codable {
    var email: String
    
    var productId: Int64
    
    var variantId: Int64
    
    var quantity: Int
}

struct NormalCartEntity: Codable {
    var orderID: Int64
    var line: [NormalLineItem]
    
}
