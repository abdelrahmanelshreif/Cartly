import Combine

class RepositoryImpl: RepositoryProtocol {
    private let remoteDataSource: RemoteDataSourceProtocol

    init(remoteDataSource: RemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchBrands() -> AnyPublisher<[BrandMapper], Error> {
        return remoteDataSource.fetchBrands()
            .tryMap {
                guard let collections = $0?.smartCollections else {
                    throw ErrorType.noData
                }
                return DataMapper.createBrands(from: collections)
            }
            .eraseToAnyPublisher()
    }
}
