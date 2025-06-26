import Foundation

enum ResultState<Value: Equatable>: Equatable{
    case loading
    case success(Value)
    case failure(String)
}

enum ResulteAuthenticationState<Value>{
    case loading
    case success(Value)
    case failure(String)
    case none
}


enum ResultStateViewLayer<T> {
    case loading
    case success(T)
    case failure(AppError)
}

enum AppError: Error {
    case failedFetchingDataFromNetwork
    case firestoreNotAvailable
    case couldNotFindTopViewController
    case googleIdTokenNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedFetchingDataFromNetwork:
            return "Failed to get product data, please try again later"
        case .firestoreNotAvailable: return "A connection to our database could not be established."
        case .couldNotFindTopViewController: return "Could not display the sign-in screen. Please try again."
        case .googleIdTokenNotFound: return "Could not get a valid token from Google. Please try again."
        }
        
    }
}
