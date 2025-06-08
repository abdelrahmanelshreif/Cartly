
import Combine

final class GetAllProductsUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[ProductMapper], Error> {
        return repository.fetchAllProducts()
    }
}
