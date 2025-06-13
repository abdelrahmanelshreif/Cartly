import Combine

class AddToCartUseCaseImpl {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error> {
        guard !cartEntity.email.isEmpty,
              cartEntity.productId > 0,
              cartEntity.variantId > 0,
              cartEntity.quantity > 0 else {
            return Fail(error: ErrorType.notValidCartData).eraseToAnyPublisher()
        }
        print("Executing AddToCart use case for: \(cartEntity.email)")
        return repository.addToCart(cartEntity: cartEntity)
            .handleEvents(
                receiveOutput: { success in
                    print("AddToCart completed with result: \(success.message)")
                },
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("AddToCart failed with error: \(error)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
