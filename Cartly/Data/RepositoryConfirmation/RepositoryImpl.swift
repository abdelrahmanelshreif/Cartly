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
    
    func fetchProducts(for collectionID: Int64) -> AnyPublisher<[ProductMapper], any Error> {
        return remoteDataSource.fetchProducts(from: collectionID)
            .tryMap {
                guard let products = $0?.products else {
                    throw ErrorType.noData
                }
                return DataMapper.createProducts(from: products)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAllProducts() -> AnyPublisher<[ProductMapper], any Error> {
        return remoteDataSource.fetchAllProducts()
            .tryMap {
                guard let products = $0?.products else {
                    throw ErrorType.noData
                }
                return DataMapper.createProducts(from: products)
            }
            .eraseToAnyPublisher()
    }
    
    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, any Error> {
        return remoteDataSource.getSingleProduct(for: productId)
    }
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, any Error> {
        return remoteDataSource.getCustomers()
    }

    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, any Error> {
        return remoteDataSource.getSingleCustomer(for: customerId)
    }
}
