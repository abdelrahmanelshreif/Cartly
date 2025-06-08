import Foundation

enum ResultState<Value>{
    case loading
    case success(Value)
    case failure(String)
}

enum ResultStateViewLayer<Value> {
    case loading
    case success(Value)
    case failure(AppError)
}

enum AppError: Error {
    case failedFetchingDataFromNetwork
    case firestoreNotAvailable
    var errorDescription: String? {
        switch self {
        case .failedFetchingDataFromNetwork:
            return "Failed to get product data, please try again later"
       
        case .firestoreNotAvailable:
        return "Failed to get product data, please try again later"
        }
        
    }
}
