import Combine

final class GetProductsUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(collectionID: Int) -> AnyPublisher<[Product], Error> {
        return repository.getProducts(for: collectionID)
    }
}
