import Combine

final class GetBrandsUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[BrandMapper], Error> {
        return repository.fetchBrands()
    }
}
