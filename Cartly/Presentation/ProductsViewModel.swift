import Combine
import Foundation

final class ProductsViewModel: ObservableObject {
    @Published private(set) var state: ResultState<[Product]> = .loading

    private var cancellables = Set<AnyCancellable>()

    private let useCase: GetProductsUseCase

    init(useCase: GetProductsUseCase) {
        self.useCase = useCase
    }

    func load(for collectio_id: Int) {
        useCase.execute(collectionID: collectio_id)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.state = .failure(error)
                }

            }, receiveValue: { [weak self] products in
                self?.state = .success(products ?? [])
            })
            .store(in: &cancellables)
    }
}
