import Combine

class GetCustomerCartUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[CartMapper], Error> {
        return repository.getAllDraftOrdersForCustomer()
    }
}
