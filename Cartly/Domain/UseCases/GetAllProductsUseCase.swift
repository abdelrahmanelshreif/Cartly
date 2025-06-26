
import Combine

protocol GetAllProductsUseCaseProtocol {
    func execute() -> AnyPublisher<[ProductMapper], Error>
}

open class GetAllProductsUseCase: GetAllProductsUseCaseProtocol {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[ProductMapper], Error> {
        return repository.fetchAllProducts()
    }
}
