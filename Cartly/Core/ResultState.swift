import Foundation

enum ResultState<Value>{
    case loading
    case success(Value)
    case failure(Error)
}

