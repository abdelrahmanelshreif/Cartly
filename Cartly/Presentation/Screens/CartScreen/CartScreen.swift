import SwiftUI

struct CartScreen: View {
    @StateObject private var viewModel: CartViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var animateTotal: Bool = false
    @State private var showCheckoutAnimation: Bool = false
    @EnvironmentObject private var currencyConverter: CurrencyManager

    init() {
        let repository = RepositoryImpl(
            remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
            firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
        )

        _viewModel = StateObject(wrappedValue: CartViewModel(
            getCustomerCartUseCase: GetCustomerCartUseCase(repository: repository),
            deleteCartItemUseCase: DeleteCartItemUseCase(repository: repository),
            getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase(repository: repository),
            addToCartUseCase: AddToCartUseCaseImpl(repository: repository)
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView()
                } else if viewModel.isCartEmpty {
                    emptyCartView()
                } else {
                    cartContentView(geometry: geometry)
                }

                if viewModel.isDeletingItem || viewModel.isUpdatingQuantity {
                    operationOverlay()
                }
            }
        }
        .navigationTitle("CART")
        .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            viewModel.loadCustomerCart()
            withAnimation(.easeInOut(duration: 0.6)) {
                animateTotal = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func loadingView() -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)

            Text("Loading your cart...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func emptyCartView() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(spacing: 12) {
                Text("Your cart is empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Add some products to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func cartContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.cartItems, id: \.orderID) { cartMapper in
                        ForEach(cartMapper.itemsMapper, id: \.itemId) { item in
                            OptimizedCartItemView(
                                item: item,
                                isLoading: viewModel.isDeletingItem || viewModel.isUpdatingQuantity,
                                onQuantityChange: { newQuantity in
                                    viewModel.updateQuantity(
                                        cartId: cartMapper.orderID,
                                        itemId: item.itemId,
                                        newQuantity: newQuantity
                                    )
                                },
                                onDelete: {
                                    viewModel.removeItem(
                                        cartId: cartMapper.orderID,
                                        itemId: item.itemId
                                    )
                                },
                                onItemTap: {
                                    router.push(Route.productDetailFromCart(
                                        productId: item.productId,
                                        isFromCart: true,
                                        variantId: item.variantId
                                    ))
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            checkoutSection(geometry: geometry)
        }
    }

    private func checkoutSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalItemsCount)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currencyConverter.format(viewModel.totalPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCheckoutAnimation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showCheckoutAnimation = false
                    if !viewModel.isCartEmpty {
                        router.push(Route.OrderCompletingScreen(viewModel.cartItems.first!))
                    }
                }
            }) {
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("Proceed to Checkout")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    viewModel.isCartEmpty ? Color.gray : Color.blue
                )
                .cornerRadius(12)
            }
            .disabled(viewModel.isCartEmpty || viewModel.isDeletingItem || viewModel.isUpdatingQuantity)
            .scaleEffect(showCheckoutAnimation ? 1.02 : 1.0)
            .padding(.horizontal, 20)
            .padding(.bottom, geometry.safeAreaInsets.bottom + 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func operationOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)

                Text(viewModel.isDeletingItem ? "Removing item..." : "Updating quantity...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

struct OptimizedCartItemView: View {
    @EnvironmentObject private var currencyConverter: CurrencyManager
    let item: ItemsMapper
    let isLoading: Bool
    let onQuantityChange: (Int) -> Void
    let onDelete: () -> Void
    let onItemTap: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        Button(action: onItemTap) {
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: item.itemImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.productTitle)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)

                    if !item.variantTitle.isEmpty {
                        Text(item.variantTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }

                    HStack {
                        Text("\(currencyConverter.format(Double(item.price) ?? 0))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

                        Spacer()

                        HStack(spacing: 8) {
                            Button(action: {
                                if item.quantity > 1 {
                                    onQuantityChange(item.quantity - 1)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(item.quantity <= 1 ? .gray : .blue)
                            }
                            .disabled(item.quantity <= 1 || isLoading)

                            Text("\(item.quantity)")
                                .font(.headline)
                                .fontWeight(.medium)
                                .frame(minWidth: 30)

                            Button(action: {
                                onQuantityChange(item.quantity + 1)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(item.quantity >= 5 ? .gray : .blue)
                            }
                            .disabled(isLoading || item.quantity >= 5)
                        }
                    }
                }

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .disabled(isLoading)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .opacity(isLoading ? 0.6 : 1.0)
        .confirmationDialog("Remove Item", isPresented: $showDeleteConfirmation) {
            Button("Remove", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove \(item.productTitle) from your cart?")
        }
    }
}
