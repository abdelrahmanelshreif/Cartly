
@testable import Cartly
import Combine
import Foundation

class MockGetProductsForCategoryId: GetProductsForCategoryIdProtocol {
    var mockProductsByCategory: [Int64: [ProductMapper]] = [:]
    var shouldReturnError = false
    var errorToReturn: Error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock category error occurred"])

    private(set) var executeCallCount = 0
    private(set) var lastCategoryId: Int64?

    func execute(for category_id: Int64) -> AnyPublisher<[ProductMapper], Error> {
        executeCallCount += 1
        lastCategoryId = category_id

        if shouldReturnError {
            return Fail(error: errorToReturn)
                .eraseToAnyPublisher()
        } else {
            let products = mockProductsByCategory[category_id] ?? []
            return Just(products)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
