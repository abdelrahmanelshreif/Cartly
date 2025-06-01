import Combine
import Foundation

protocol HomeViewModelProtocol {
    func loadBrands()
}

class HomeViewModel: ObservableObject, HomeViewModelProtocol {
    @Published private(set) var state: ResultState<[BrandMapper]> = .loading
    @Published private(set) var cartState: ResultState<Int> = .loading
    private let getBrandUseCase: GetBrandsUseCase
    private var cancellables: Set<AnyCancellable> = []

    init(getBrandUseCase: GetBrandsUseCase) {
        self.getBrandUseCase = getBrandUseCase
    }

    func loadBrands() {
        state = .loading
        getBrandUseCase.execute()
            .sink(receiveCompletion: { [weak self] in
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    self?.state = .failure(error.localizedDescription)
                }
            }, receiveValue: { [weak self] in
                self?.state = .success($0)
            })
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
