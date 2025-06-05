import Combine


class RepositoryImpl: RepositoryProtocol{
    
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
    
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, any Error> {
        return remoteDataSource.getProducts(from: collectionID)
    }
    
    func getSingleProduct(for productId: Int) -> AnyPublisher<SingleProductResponse?, any Error> {
        return remoteDataSource.getSingleProduct(for: productId)
    }
    
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, any Error> {
        return remoteDataSource.getCustomers()
    }

    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, any Error> {
        return remoteDataSource.getSingleCustomer(for: customerId)
    }
}
