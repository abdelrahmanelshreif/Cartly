import Combine

protocol RepositoryProtocol {

    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, Error>
    func getSingleProduct(for productId: Int) -> AnyPublisher<SingleProductResponse?, Error>
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error>
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<[WishlistProduct]?, Error>
    func addWishlistProductForUser(whoseId id: String, withProduct product: WishlistProduct) -> AnyPublisher<Void, Error>
    func removeWishlistProductForUser(whoseId id: String, withProduct productId: String) -> AnyPublisher<Void, Error>
    func isProductInWishlist(withProduct productId: String, forUser id: String)-> AnyPublisher<Bool, Error>
}
