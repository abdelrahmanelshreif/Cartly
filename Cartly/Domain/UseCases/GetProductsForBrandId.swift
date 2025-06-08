import Combine

final class GetProductsForBrandId {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(for brand_id: Int64) -> AnyPublisher<[ProductMapper], Error> {
        return repository.fetchProducts(for: brand_id)
    }
}
