
@testable import Cartly
import Combine
import Foundation

class MockGetAllProductsUseCase: GetAllProductsUseCaseProtocol {
    var mockProducts: [ProductMapper] = []
    var shouldReturnError = false
    var errorToReturn: Error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error occurred"])

    private(set) var executeCallCount = 0

    func execute() -> AnyPublisher<[ProductMapper], Error> {
        executeCallCount += 1

        if shouldReturnError {
            return Fail(error: errorToReturn)
                .eraseToAnyPublisher()
        } else {
            return Just(mockProducts)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
