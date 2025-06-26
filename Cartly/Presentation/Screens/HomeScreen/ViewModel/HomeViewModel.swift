import Combine
import Foundation

protocol HomeViewModelProtocol: ObservableObject {
    var brandState: ResultState<[BrandMapper]> { get }
    var cartState: ResultState<Int> { get }
    var userSessionServices: UserSessionService { get }

    func loadBrands()
}

class HomeViewModel: ObservableObject, HomeViewModelProtocol {
    @Published private(set) var brandState: ResultState<[BrandMapper]> = .loading
    @Published private(set) var cartState: ResultState<Int> = .loading

    private let getBrandUseCase: GetBrandsUseCase
    private var cancellables: Set<AnyCancellable> = []

    var userSessionServices: UserSessionService = UserSessionService()
    init(
        getBrandUseCase: GetBrandsUseCase
    ) {
        self.getBrandUseCase = getBrandUseCase
    }

    func loadBrands() {
        print("isUserEmailVerified: \(FirebaseServices.getUserVerificationStatus())")
        brandState = .loading
        getBrandUseCase.execute()
            .sink(receiveCompletion: { [weak self] in
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    self?.brandState = .failure(error.localizedDescription)
                }
            }, receiveValue: { [weak self] in
                self?.brandState = .success($0)
            })
            .store(in: &cancellables)
    }
}
