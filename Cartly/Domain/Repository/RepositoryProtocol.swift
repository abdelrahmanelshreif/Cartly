import Combine

protocol RepositoryProtocol {
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>

    func fetchProducts(for collectionID: Int64) -> AnyPublisher<[ProductMapper], Error>

    func fetchAllProducts() -> AnyPublisher<[ProductMapper], Error>

    //  func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, Error>

    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, Error>
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error>

    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>

    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<[WishlistProduct]?, Error>

    func addWishlistProductForUser(whoseId id: String, withProduct product: WishlistProduct) -> AnyPublisher<Void, Error>

    func removeWishlistProductForUser(whoseId id: String, withProduct productId: String) -> AnyPublisher<Void, Error>

    func isProductInWishlist(withProduct productId: String, forUser id: String) -> AnyPublisher<Bool, Error>

    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error>

    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<DraftOrder?, Error>

    func editDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error>

    func addToCart(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error>

    func getAllDraftOrdersForCustomer() -> AnyPublisher<[CartMapper], Error>

    func deleteExistingDraftOrder(draftOrderID: Int64, itemID: Int64)
        -> AnyPublisher<[CartMapper], Error>
    
    func getAllProductsToGetLineItemsPhoto(cartMapper: CartMapper) -> AnyPublisher<[CartMapper], Error> 
}
