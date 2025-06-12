import Foundation

enum ErrorType: LocalizedError{
    case noData
    case noInternet
    case badServerResponse
    case failUnWrapself
    case failToAddNewItem
    case notValidCartData
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data Retured from server"
        case .noInternet:
            return "No internet connection"
        case .badServerResponse:
            return "Bad server response"
        case .failUnWrapself:
            return "Fail UnWrap self"
        case .failToAddNewItem:
            return "Fail To Add New Item"
        case .notValidCartData:
            return "Not Valid Data Enter Valid Quantity and check Size and Color!"
        }
    }
}


enum CustomSuccess {
    case Added
    case AlreadyExist
    var message: String {
        switch self {
        case .Added:
            return "Item successfully added to cart"
        case .AlreadyExist:
            return "Item quantity updated in cart"
        }
    }
}
