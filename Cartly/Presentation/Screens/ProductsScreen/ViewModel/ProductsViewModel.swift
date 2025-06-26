import Combine
import SwiftUI

protocol ProductsViewModelProtocol: ObservableObject {
    var productState: ResultState<[ProductMapper]> { get }
    var cartState: ResultState<Int> { get }

    func loadProducts(brandId: Int64)
}

class ProductsViewModel: ProductsViewModelProtocol {
    @Published private(set) var productState: ResultState<[ProductMapper]> = .loading
    @Published private(set) var cartState: ResultState<Int> = .loading
    private let useCase: GetProductsForBrandId
    private var cancellables: Set<AnyCancellable> = []

    init(useCase: GetProductsForBrandId) {
        self.useCase = useCase
    }

    func loadProducts(brandId: Int64) {
        productState = .loading
        useCase.execute(for: brandId)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case let .failure(error):
                    self?.productState = .failure(error.localizedDescription)
                }
            } receiveValue: { [weak self] products in
                self?.productState = .success(products)
            }
            .store(in: &cancellables)
    }
}
