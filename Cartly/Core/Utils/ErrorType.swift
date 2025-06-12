import Foundation

enum ErrorType: LocalizedError{
    case noData
    case noInternet
    case badServerResponse
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data Retured from server"
        case .noInternet:
            return "No internet connection"
        case .badServerResponse:
            return "Bad server response"
        }
    }
}
enum PromoError: LocalizedError {
    case codeNotFound
    case exceededUsageLimit
    case insufficientSubtotal(minRequired: Double)
    case totalExceedsCashOnDeliveryLimit
    case unknown

    var errorDescription: String? {
        switch self {
        case .codeNotFound:
            return "Coupon code not found."
        case .exceededUsageLimit:
            return "This coupon has reached its usage limit."
        case .insufficientSubtotal(let min):
            return "You need to spend at least $\(String(format: "%.2f", min)) to use this coupon."
        case .totalExceedsCashOnDeliveryLimit:
            return "Cash on Delivery is not available for orders above $1000."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
