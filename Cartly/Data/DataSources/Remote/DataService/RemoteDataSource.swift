import Combine

protocol RemoteDataSourceProtocol {
    func fetchBrands() -> AnyPublisher<SmartCollectionsResponse?, Error>

    func getProducts(from collection_id: Int) -> AnyPublisher<[Product]?, Error>
    
    func getSingleProduct(for productId:Int) -> AnyPublisher<SingleProductResponse? , Error>
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error>
    
    func getSingleCustomer(for customerId:String) -> AnyPublisher<CustomerResponse?, Error>
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
    
    
    func getSingleProduct(for productId: Int) -> AnyPublisher<SingleProductResponse?, any Error> {
        let requset = APIRequest(
            withMethod: .GET,
            withPath: "/products/\(productId).json")
        
        return networkService.request(requset, responseType: SingleProductResponse.self)
    }
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, any Error> {
        let request = APIRequest(
            withMethod: .GET,
            withPath: "/customers.json")
        return networkService.request(request, responseType: AllCustomerResponse.self)
    }
    
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, any Error> {
        let request = APIRequest(
            withMethod: .GET,
            withPath: "/customers/\(customerId).json")
        
        return networkService.request(request, responseType: CustomerResponse.self)
    }
}
