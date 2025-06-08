import Combine

protocol RepositoryProtocol{
    
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>
//    func getCustomers() -> AnyPublisher<[CustomerResponse]? , Error>
//    func getCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
    
    func fetchProducts(for collectionID: Int64) -> AnyPublisher<[ProductMapper], Error>
    
    func fetchAllProducts() -> AnyPublisher<[ProductMapper], Error>
    
    func getSingleProduct(for productId:Int64) -> AnyPublisher<SingleProductResponse? , Error>
    func getCustomers() -> AnyPublisher<AllCustomerResponse? , Error>
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
}
