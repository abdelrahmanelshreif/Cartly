import Combine

final class GetProductsForCategoryId {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(for category_id: Int64) -> AnyPublisher<[ProductMapper], Error> {
        return repository.fetchProducts(for: category_id)
    }
}
