import Combine
import SwiftUI

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartMapper] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasItems: Bool = false
    @Published var isDeletingItem: Bool = false

    private let deleteCartItemUseCase: DeleteCartItemUseCase
    private let getCustomerCartUseCase: GetCustomerCartUseCase
    private let getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase
    private var cancellables = Set<AnyCancellable>()

    var isCartEmpty: Bool {
        return cartItems.isEmpty
    }

    var totalItemsCount: Int {
        return cartItems.reduce(0) { total, cart in
            total + cart.itemsMapper.reduce(0) { $0 + $1.quantity }
        }
    }

    var totalPrice: Double {
        return cartItems.reduce(0.0) { total, cart in
            total + cart.itemsMapper.reduce(0.0) { subtotal, item in
                subtotal + (Double(item.price) ?? 0.0) * Double(item.quantity)
            }
        }
    }

    init(
        getCustomerCartUseCase: GetCustomerCartUseCase,
        deleteCartItemUseCase: DeleteCartItemUseCase,
        getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase
    ) {
        self.getCustomerCartUseCase = getCustomerCartUseCase
        self.deleteCartItemUseCase = deleteCartItemUseCase
        self.getCartItemsWithImagesUseCase = getCartItemsWithImagesUseCase
    }

    func loadCustomerCart() {
        isLoading = true
        errorMessage = nil

        getCustomerCartUseCase.execute()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] cartMappers in
                    self?.cartItems = cartMappers
                    self?.hasItems = !cartMappers.isEmpty
                    self?.isLoading = false
                    if !cartMappers.isEmpty {
                        self?.loadAllProductsToGetImages(cartMapper: cartMappers.first!)
                    }
                    print("Loaded \(cartMappers.count) cart items for customer")
                }
            )
            .store(in: &cancellables)
    }

    func loadAllProductsToGetImages(cartMapper: CartMapper) {
        getCartItemsWithImagesUseCase.execute(cartMapper: cartMapper)
            .sink(receiveCompletion: { [weak self] in
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] cartMappers in
                self?.cartItems = cartMappers
                self?.hasItems = !cartMappers.isEmpty
                self?.isLoading = false

                print("Loaded \(cartMappers.count) cart items for customer")
            })
            .store(in: &cancellables)
    }

    func refreshCart() {
        loadCustomerCart()
    }

    func removeItem(cartId: Int64, itemId: Int64) {
        isDeletingItem = true
        errorMessage = nil

        deleteCartItemUseCase.execute(draftOrderID: cartId, itemID: itemId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isDeletingItem = false

                    switch completion {
                    case .finished:
                        print("Item deleted successfully")
                    case let .failure(error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] updatedCartMappers in
                    self?.cartItems = updatedCartMappers
                    self?.hasItems = !updatedCartMappers.isEmpty
                    print("Cart updated after deletion. Items count: \(updatedCartMappers.count)")
                }
            )
            .store(in: &cancellables)
    }

    func updateQuantity(cartId: Int64, itemId: Int64, newQuantity: Int) {
        // TODO: Implement update quantity logic
        print("Update item \(itemId) quantity to \(newQuantity) in cart \(cartId)")
    }

    private func handleError(_ error: Error) {
        if let customError = error as? ErrorType {
            switch customError {
            case .noData:
                errorMessage = "No cart items found"
            case .noInternet:
                errorMessage = "Please check your internet connection"
            case .badServerResponse:
                errorMessage = "Server error occurred"
            default:
                errorMessage = customError.localizedDescription
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        print("Cart loading error: \(errorMessage ?? "Unknown error")")
    }
}
