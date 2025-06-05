import Combine

protocol RemoteDataSourceProtocol {
    func fetchBrands() -> AnyPublisher<SmartCollectionsResponse?, Error>
}

final class RemoteDataSourceImpl: RemoteDataSourceProtocol {
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchBrands() -> AnyPublisher<SmartCollectionsResponse?, Error> {
        let request = APIRequest(
            withPath: "/smart_collections.json"
        )
        return networkService.request(request, responseType: SmartCollectionsResponse.self)
    }
    
    func getProducts(from collection_id: Int) -> AnyPublisher<[Product]?, any Error> {
        
        let path = "/products.json?collection_id=\(collection_id)"
        let apiRequest = APIRequest(withPath: path)

        return networkService.request(apiRequest, responseType: ProductListResponse.self)
            .map {
                $0?.products ?? []
            }
            .eraseToAnyPublisher()
    }
    
}
