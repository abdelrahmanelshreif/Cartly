import Combine
import Foundation

class ProductDetailsViewModel: ObservableObject {
    @Published var resultState:
        ResultStateViewLayer<ProductInformationEntity>? = nil
    @Published var selectedSize = "" {
        didSet {
            updateSelectedVariant()
        }
    }

    @Published var selectedColor = "" {
        didSet {
            updateSelectedVariant()
        }
    }

    @Published var alertMessage = ""
    @Published var triggerAlert = false
    @Published var quantity = 1
    @Published var selectedVariant: ProductInformationVariantEntity? = nil
    @Published var isAddToCartEnabled = false
    @Published var showQuantitySelector = false

    /// new added for cart logic
    ///
    ///
    @Published var isAddingToCart = false
    private let addToCartUseCase: AddToCartUseCaseImpl
    private let maxCartQuantity = 5
    private let userSession: UserSessionService = UserSessionService()

    private let getProductUseCase: GetProductDetailsUseCaseProtocol
    private var currentProduct: ProductInformationEntity?
    private var cancellables = Set<AnyCancellable>()

//    //Handling Varient Comes Form Cart
//    private var productComesFromCartWisthSpecifiedVariation = false
//    private var varientIdComesFromCart: Int64 = 0

    init(getProductUseCase: GetProductDetailsUseCaseProtocol) {
        self.getProductUseCase = getProductUseCase
        addToCartUseCase = AddToCartUseCaseImpl(
            repository: RepositoryImpl(
                remoteDataSource: RemoteDataSourceImpl(
                    networkService: AlamofireService()),
                firebaseRemoteDataSource: FirebaseDataSource(
                    firebaseServices: FirebaseServices())))
    }

    func getProduct(for productId: Int64, sourceisCart isComesFromCart:Bool = false , cartVarientId varientId:Int64 = 0) {
        resultState = .loading
        getProductUseCase.execute(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case let .success(productResponse):
                    guard let product = productResponse else { return }
                    let mappedProduct =
                        ProducInformationtMapper.mapShopifyProductToProductView(
                            product)
                    self?.currentProduct = mappedProduct
                    self?.resultState = .success(mappedProduct)
                    self?.resetSelection()

                    if isComesFromCart {
                        self?.selectedVariant = self?.currentProduct?.variants.first { varient in
                            varient.id == varientId
                        }
                        self?.selectedSize = self?.selectedVariant?.size ?? ""
                        self?.selectedColor = self?.selectedVariant?.color ?? ""
                        
                    } else {
                        if mappedProduct.availableSizes.count == 1 {
                            self?.selectedSize = mappedProduct.availableSizes[0]
                        }
                        if mappedProduct.availableColors.count == 1 {
                            self?.selectedColor =
                                mappedProduct.availableColors[0]
                        }
                    }

                case .failure:
                    self?.resultState = .failure(
                        AppError.failedFetchingDataFromNetwork)
                }
            }
            .store(in: &cancellables)
    }

    private func resetSelection() {
        selectedSize = ""
        selectedColor = ""
        quantity = 1
        selectedVariant = nil
        showQuantitySelector = false
        isAddToCartEnabled = false
    }

    private func updateSelectedVariant() {
        guard let product = currentProduct else {
            selectedVariant = nil
            showQuantitySelector = false
            return
        }

        print(
            "Updating variant - Size: \(selectedSize), Color: \(selectedColor)")

        // Check if both size and color are selected
        let sizeRequired = !product.availableSizes.isEmpty
        let colorRequired = !product.availableColors.isEmpty

        let sizeSelected = !sizeRequired || !selectedSize.isEmpty
        let colorSelected = !colorRequired || !selectedColor.isEmpty

        if !sizeSelected || !colorSelected {
            selectedVariant = nil
            showQuantitySelector = false
            isAddToCartEnabled = false
            return
        }

        // Find matching variant
        selectedVariant = product.variants.first { variant in
            let sizeMatch = !sizeRequired || variant.size == selectedSize
            let colorMatch = !colorRequired || variant.color == selectedColor
            return sizeMatch && colorMatch
        }

        // Update UI state based on variant selection
        if let variant = selectedVariant {
            showQuantitySelector = true
            // Reset quantity to 1 when variant changes, but only if current quantity exceeds stock
            if quantity > variant.inventoryQuantity {
                quantity = min(1, variant.inventoryQuantity)
            }
            isAddToCartEnabled =
                variant.isAvailable && variant.inventoryQuantity > 0
        } else {
            showQuantitySelector = false
            isAddToCartEnabled = false
        }
    }

    // Rest of your methods remain the same...
    func incrementQuantity() {
        guard let variant = selectedVariant else { return }
        if quantity < variant.inventoryQuantity {
            quantity += 1
        }
    }

    func decrementQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }

    func canIncrementQuantity() -> Bool {
        guard let variant = selectedVariant else { return false }
        return quantity < variant.inventoryQuantity && variant.isAvailable
    }

    func canDecrementQuantity() -> Bool {
        return quantity > 1
    }

    var maxQuantity: Int {
        return selectedVariant?.inventoryQuantity ?? 1
    }

    var availableStock: Int {
        return selectedVariant?.inventoryQuantity ?? 0
    }

    var isVariantAvailable: Bool {
        return selectedVariant?.isAvailable ?? false
    }

    var variantPrice: Double? {
        return selectedVariant?.price
    }

    
    func addToCart() {
        guard let variant = selectedVariant else {
            alertMessage =
                "Please select size and color to continue shopping..."
            triggerAlert = true
            return
        }

        guard variant.isAvailable else {
            alertMessage = "This variant is currently unavailable"
            triggerAlert = true
            return
        }

        guard variant.inventoryQuantity > 0 else {
            alertMessage = "This variant is out of stock"
            triggerAlert = true
            return
        }

        guard quantity <= variant.inventoryQuantity else {
            alertMessage = "Requested quantity exceeds available stock"
            triggerAlert = true
            return
        }

        guard quantity <= maxCartQuantity else {
            alertMessage = "Maximum quantity per item is \(maxCartQuantity)"
            triggerAlert = true
            return
        }

        guard let userEmail = userSession.getCurrentUserEmail() else {
            alertMessage = "Please login to add items to cart"
            triggerAlert = true
            return
        }

        let cartEntity = CartEntity(
            email: userEmail,
            productId: currentProduct!.id,
            variantId: variant.id,
            quantity: quantity
        )

        // Set loading state
        isAddingToCart = true
        isAddToCartEnabled = false

        addToCartUseCase.execute(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isAddingToCart = false
                    self?.updateAddToCartButtonState()

                    if case let .failure(error) = completion {
                        self?.handleAddToCartError(error)
                    }
                },
                receiveValue: { [weak self] success in
                    self?.handleAddToCartSuccess(success)
                }
            )
            .store(in: &cancellables)

        print(
            "Adding to cart: Variant ID: \(variant.id), Title: \(variant.title), Quantity: \(quantity), Price: \(variant.price)"
        )

        // Show success message
        alertMessage = "Added to cart successfully!"
        triggerAlert = true
    }

    private func handleAddToCartSuccess(_ success: CustomSuccess) {
        switch success {
        case .Added:
            alertMessage = "Item added to cart successfully!"
        case .AlreadyExist:
            alertMessage = "Cart updated successfully!"
        }
        triggerAlert = true
    }

    private func handleAddToCartError(_ error: Error) {
        if let errorType = error as? ErrorType {
            switch errorType {
            case .notValidCartData:
                alertMessage = "Invalid cart data. Please try again."
            case .noData:
                alertMessage = "No data available. Please try again."
            case .failUnWrapself:
                alertMessage = "An unexpected error occurred. Please try again."
            default:
                alertMessage = "Failed to add item to cart. Please try again."
            }
        } else {
            alertMessage =
                "Failed to add item to cart: \(error.localizedDescription)"
        }
        triggerAlert = true
    }

    private func updateAddToCartButtonState() {
        guard let variant = selectedVariant else {
            isAddToCartEnabled = false
            return
        }
        isAddToCartEnabled =
            variant.isAvailable && variant.inventoryQuantity > 0
            && !isAddingToCart
    }
}
