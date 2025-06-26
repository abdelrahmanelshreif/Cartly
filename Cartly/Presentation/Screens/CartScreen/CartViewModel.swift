import Combine
import SwiftUI

protocol CartViewModelProtocol: ObservableObject {
    var cartItems: [CartMapper] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var hasItems: Bool { get set }
    var isDeletingItem: Bool { get set }
    var isUpdatingQuantity: Bool { get set }

    var isCartEmpty: Bool { get }
    var totalItemsCount: Int { get }
    var totalPrice: Double { get }

    func loadCustomerCart()
    func loadAllProductsToGetImages(cartMapper: CartMapper)
    func removeItem(cartId: Int64, itemId: Int64)
    func updateQuantity(cartId: Int64, itemId: Int64, newQuantity: Int)
}

class CartViewModel: CartViewModelProtocol {
    @Published var cartItems: [CartMapper] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasItems: Bool = false
    @Published var isDeletingItem: Bool = false
    @Published var isUpdatingQuantity: Bool = false

    private let deleteCartItemUseCase: DeleteCartItemUseCase
    private let getCustomerCartUseCase: GetCustomerCartUseCase
    private let getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase
    private let addToCartUseCase: AddToCartUseCaseImpl

    private let userSession: UserSessionService = UserSessionService()
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
        getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase,
        addToCartUseCase: AddToCartUseCaseImpl
    ) {
        self.getCustomerCartUseCase = getCustomerCartUseCase
        self.deleteCartItemUseCase = deleteCartItemUseCase
        self.getCartItemsWithImagesUseCase = getCartItemsWithImagesUseCase
        self.addToCartUseCase = addToCartUseCase
    }

    func loadCustomerCart() {
        isLoading = true
        errorMessage = nil
        getCustomerCartUseCase.execute()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    print("loadCustomerCart Done here!!!!")
                    switch completion {
                    case .finished:
                        guard let hasItems = self?.hasItems,
                              let cartItems = self?.cartItems else {
                            return
                        }
                        if hasItems {
                            self?.loadAllProductsToGetImages(cartMapper: cartItems.first!)
                        }
                        break
                    case let .failure(error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] cartMappers in
                    self?.cartItems = cartMappers
                    self?.hasItems = !cartMappers.isEmpty
                    self?.isLoading = false
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
                        if let cartItems = self?.cartItems, !cartItems.isEmpty {
                            self?.loadAllProductsToGetImages(cartMapper: cartItems.first!)
                        }
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
        guard let userEmail = userSession.getCurrentUserEmail() else {
            return
        }

        guard let item = cartItems.first?.itemsMapper.first(where: { $0.itemId == itemId }) else {
            errorMessage = "Item not found in cart"
            return
        }

        if item.quantity == newQuantity {
            return
        }

        if (item.currentInStock! - item.quantity) <= 0 {
            errorMessage = "Item out of stock"
            return
        }

        if newQuantity > 5 || (item.currentInStock! - item.quantity) < newQuantity {
            errorMessage = "Can not Increase More Than 5 Items"
            return
        }

        isUpdatingQuantity = true
        errorMessage = nil

        let cartEntity = CartEntity(
            email: userEmail,
            productId: item.productId,
            variantId: item.variantId,
            quantity: newQuantity
        )

        addToCartUseCase.execute(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isUpdatingQuantity = false
                    switch completion {
                    case .finished:
                        print("Quantity updated successfully")
                    // self?.loadCustomerCart()
                    case let .failure(error):
                        self?.handleError(error)
                        self?.loadCustomerCart()
                    }
                },
                receiveValue: { [weak self] success in
                    guard let itemIndex = self?.cartItems[0].itemsMapper.firstIndex(where: { $0.itemId == itemId }) else {
                        return
                    }
                    self?.cartItems[0].itemsMapper[itemIndex].quantity = newQuantity
                    print("\(String(describing: self?.cartItems[0].itemsMapper))")
                    switch success {
                    case .Added:
                        print("Item quantity updated successfully")
                    case .AlreadyExist:
                        print("Cart quantity updated")
                    }
                }
            )
            .store(in: &cancellables)

        print("Updating item \(itemId) quantity to \(newQuantity) in cart \(cartId)")
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
            case .notValidCartData:
                errorMessage = "Invalid cart data"
            default:
                errorMessage = customError.localizedDescription
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        print("Cart error: \(errorMessage ?? "Unknown error")")
    }
}
