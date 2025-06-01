import Combine

protocol RepositoryProtocol {
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>
}
