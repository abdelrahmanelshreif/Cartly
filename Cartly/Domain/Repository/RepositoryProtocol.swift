import Combine

protocol RepositoryProtocol{
    
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error>
//    func getCustomers() -> AnyPublisher<[CustomerResponse]? , Error>
//    func getCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error>
}
