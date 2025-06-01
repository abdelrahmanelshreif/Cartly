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
