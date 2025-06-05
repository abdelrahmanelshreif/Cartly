import Combine

protocol RepositoryProtocol{
    
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>
//    func getCustomers() -> AnyPublisher<[CustomerResponse]? , Error>
//    func getCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, Error>
    func getSingleProduct(for productId:Int) -> AnyPublisher<SingleProductResponse? , Error>
    func getCustomers() -> AnyPublisher<AllCustomerResponse? , Error>
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
}
