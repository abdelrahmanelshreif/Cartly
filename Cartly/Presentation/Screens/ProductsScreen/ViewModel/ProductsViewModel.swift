import SwiftUI
import Combine

class ProductsViewModel: ObservableObject{
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
            .sink {[weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.productState = .failure(error.localizedDescription)
                }
            } receiveValue: {[weak self] products in
                self?.productState = .success(products)
            }
            .store(in: &cancellables)
    }
    
    func loadCartItemCount() {
            cartState = .loading
            Just(5)
                .delay(for: .seconds(2), scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.cartState = .failure(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] count in
                    self?.cartState = .success(count)
                })
                .store(in: &cancellables)
        }
    
}
