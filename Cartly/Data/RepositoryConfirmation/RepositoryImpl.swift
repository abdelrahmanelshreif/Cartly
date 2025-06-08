import Combine

class RepositoryImpl: RepositoryProtocol{

    private let remoteDataSource: RemoteDataSourceProtocol
    private let firebaseRemoteDataSource: FirebaseDataSourceProtocol
    
    init(remoteDataSource: RemoteDataSourceProtocol, firebaseRemoteDataSource: FirebaseDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.firebaseRemoteDataSource = firebaseRemoteDataSource
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
    
    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<[WishlistProduct]?, any Error> {
        return firebaseRemoteDataSource.getWishlistProductsForUser(whoseId: id)
    }
    
    func addWishlistProductForUser(whoseId id: String, withProduct product: WishlistProduct) -> AnyPublisher<Void, any Error> {
        firebaseRemoteDataSource.addWishlistProductForUser(whoseId: id, withProduct: product)
    }
    
    func removeWishlistProductForUser(whoseId id: String, withProduct productId: String) -> AnyPublisher<Void, any Error> {
        firebaseRemoteDataSource.removeWishlistProductForUser(whoseId: id, withProduct: productId)
    }
    
    func isProductInWishlist(withProduct productId: String, forUser id: String) -> AnyPublisher<Bool, any Error> {
        firebaseRemoteDataSource.isProductInWishlist(withProduct: productId, forUser: id)
    }
}
