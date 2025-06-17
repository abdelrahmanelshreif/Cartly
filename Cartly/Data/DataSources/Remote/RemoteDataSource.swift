import Combine

protocol RemoteDataSourceProtocol {
    func fetchBrands() -> AnyPublisher<SmartCollectionsResponse?, Error>
    
    func fetchProducts(from collection_id: Int64) -> AnyPublisher<ProductListResponse?, Error>
    
    func fetchAllProducts() -> AnyPublisher<ProductListResponse?, Error>
    
    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, Error>
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error>
    
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
    
    /// for order
    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error>
    
    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<DraftOrder?, Error>
    
    func editExistingDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error>
    
    func deleteExistingDraftOrder(draftOrderID: Int64) -> AnyPublisher<Bool, Error>
    
    func completeDraftOrder(id: Int) -> AnyPublisher<Void, Error>
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
    
    func fetchProducts(from collection_id: Int64) -> AnyPublisher<ProductListResponse?, any Error> {
        let request = APIRequest(
            withPath: "/products.json?collection_id=\(collection_id)"
        )
        return networkService.request(request, responseType: ProductListResponse.self)
    }
    
    func fetchAllProducts() -> AnyPublisher<ProductListResponse?, any Error> {
        let request = APIRequest(
            withPath: "/products.json"
        )
        return networkService.request(request, responseType: ProductListResponse.self)
    }
    
    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, any Error> {
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
    
    /// All drafts
    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error> {
        let request = APIRequest(
            withPath: "/draft_orders.json"
        )
        
        return networkService.request(request, responseType: DraftOrdersResponse.self)
    }
    
    /// Post New
    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<DraftOrder?, Error> {
        let request = APIRequest(
            withMethod: .POST,
            withPath: "/draft_orders.json",
            withParameters: MapCartToDraftOrderRequestDic(cart: cartEntity)
        )
        print("\(MapCartToDraftOrderRequestDic(cart: cartEntity)) in remoooooote")
        return networkService.request(request, responseType: DraftOrderResponse.self)
            .map {
                $0?.draftOrder
            }
            .eraseToAnyPublisher()
    }
    func completeDraftOrder(id: Int) -> AnyPublisher<Void, Error> {
        let request = APIRequest(
            withMethod: .PUT,
            withPath: "/draft_orders/\(id)/complete.json"
        )
        
        return networkService
            .request(request, responseType: EmptyResponse.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    /// edit draft
    func editExistingDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error> {
        let request = APIRequest(
            withMethod: .PUT,
            /// force unwrap for draft order id cuz we have it already if we make put request
            withPath: "/draft_orders/\(draftOrder.id!).json",
            withParameters: mapDraftOrderToDict(draftOrder)
        )
        print(mapDraftOrderToDict(draftOrder))
        print("/draft_orders/\(draftOrder.id!).json in remoooooote")
        return networkService.request(request, responseType: DraftOrderResponse.self)
            .map {
                $0?.draftOrder
            }
            .eraseToAnyPublisher()
    }
    
    func deleteExistingDraftOrder(draftOrderID: Int64) -> AnyPublisher<Bool, Error> {
        let request = APIRequest(
            withMethod: .DELETE,
            withPath: "/draft_orders/\(draftOrderID).json"
        )
        return networkService.request(request, responseType: EmptyResponseWhenDelete.self)
            .tryMap({ _ in
                true
            })
            .mapError({ error in
                print("failed when deleting with error: \(error)")
                return error
            })
            .eraseToAnyPublisher()
    }
    
    
    
}
