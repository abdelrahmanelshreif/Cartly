
import SwiftUI

struct CartScreen: View {
    @StateObject private var viewModel: CartViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var animateTotal: Bool = false
    @State private var showCheckoutAnimation: Bool = false
    @EnvironmentObject private var currencyConverter:CurrencyManager

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
                    //Text("$\(viewModel.totalPrice, specifier: "%.2f")")
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
        .background(Color(.systemBackground))
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
    @EnvironmentObject private var currencyConverter:CurrencyManager
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

#if false
    struct OptimizedCartItemView: View {
        let item: ItemsMapper
        let isLoading: Bool
        let onQuantityChange: (Int) -> Void
        let onDelete: () -> Void
        let onItemTap: () -> Void

        @State private var showDeleteConfirmation = false
        @State private var localQuantity: Int

        init(item: ItemsMapper, isLoading: Bool, onQuantityChange: @escaping (Int) -> Void, onDelete: @escaping () -> Void, onItemTap: @escaping () -> Void) {
            self.item = item
            self.isLoading = isLoading
            self.onQuantityChange = onQuantityChange
            self.onDelete = onDelete
            self.onItemTap = onItemTap
            _localQuantity = State(initialValue: item.quantity)
        }

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
                            Text("$\(item.price)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)

                            Spacer()

                            HStack(spacing: 8) {
                                Button(action: {
                                    if localQuantity > 1 {
                                        localQuantity -= 1
                                        onQuantityChange(localQuantity)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(localQuantity <= 1 ? .gray : .blue)
                                }
                                .disabled(localQuantity <= 1 || isLoading)

                                Text("\(localQuantity)")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .frame(minWidth: 30)

                                Button(action: {
                                    localQuantity += 1
                                    onQuantityChange(localQuantity)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(localQuantity >= 5 ? .gray : .blue)
                                }
                                .disabled(isLoading || localQuantity >= 5)
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
            .onChange(of: item.quantity) { newValue in
                localQuantity = newValue
            }
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
#endif

#if false
    import SwiftUI

    struct CartScreen: View {
        @StateObject private var viewModel: CartViewModel
        @EnvironmentObject private var router: AppRouter
        @State private var animateTotal: Bool = false
        @State private var showCheckoutAnimation: Bool = false

        init() {
            let repository = RepositoryImpl(
                remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
            )

            _viewModel = StateObject(wrappedValue: CartViewModel(
                getCustomerCartUseCase: GetCustomerCartUseCase(repository: repository),
                deleteCartItemUseCase: DeleteCartItemUseCase(repository: repository),
                getCartItemsWithImagesUseCase: GetCartItemsWithImagesUseCase(repository: repository)
            ))
        }

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.97, blue: 1.0),
                            Color(red: 0.98, green: 0.95, blue: 1.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    if viewModel.isLoading {
                        modernLoadingView()
                    } else if viewModel.isCartEmpty {
                        emptyCartView()
                    } else {
                        cartContentView(geometry: geometry)
                    }

                    if viewModel.isDeletingItem {
                        deletionOverlay()
                    }
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.large)
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

        private func modernLoadingView() -> some View {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.isLoading)
                }

                Text("Loading your cart...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        private func emptyCartView() -> some View {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "cart")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(.blue)
                        .scaleEffect(animateTotal ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateTotal)
                }

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
        }

        private func cartContentView(geometry: GeometryProxy) -> some View {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(viewModel.cartItems.enumerated()), id: \.element.orderID) { _, cartMapper in
                            VStack(spacing: 12) {
                                ForEach(Array(cartMapper.itemsMapper.enumerated()), id: \.element.itemId) { _, item in
                                    ModernCartItemView(
                                        item: item,
                                        isDeletingItem: viewModel.isDeletingItem,
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
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                modernCheckoutSection(geometry: geometry)
            }
        }

        private func modernCheckoutSection(geometry: GeometryProxy) -> some View {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)

                VStack(spacing: 20) {
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
                            Text("$\(viewModel.totalPrice, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .scaleEffect(animateTotal ? 1.0 : 0.8)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateTotal)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

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
                                .font(.headline)

                            Text("Proceed to Checkout")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(
                            Group {
                                if viewModel.isCartEmpty {
                                    Color.gray.opacity(0.6)
                                } else {
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: viewModel.isCartEmpty ? .clear : .blue.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                    }
                    .disabled(viewModel.isCartEmpty || viewModel.isDeletingItem)
                    .scaleEffect(showCheckoutAnimation ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showCheckoutAnimation)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .blur(radius: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 10)
            }
        }

        private func deletionOverlay() -> some View {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 60)

                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.isDeletingItem)
                    }

                    Text("Removing item...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.8))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .blur(radius: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }

    struct ModernCartItemView: View {
        let item: ItemsMapper
        let isDeletingItem: Bool
        let onQuantityChange: (Int) -> Void
        let onDelete: () -> Void
        let onItemTap: () -> Void

        @State private var showDeleteConfirmation = false
        @State private var itemScale: CGFloat = 1.0
        @State private var quantityAnimation: Bool = false

        var body: some View {
            Button(action: onItemTap) {
                HStack(alignment: .center, spacing: 16) {
                    #if false
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)

                            Image(systemName: "photo.artframe")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.gray)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    #endif
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)

                        if let imageURL = item.itemImage, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90)
                                    .clipped()
                                    .cornerRadius(16)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                            }
                        } else {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.gray)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.productTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundColor(.primary)

                        if !item.variantTitle.isEmpty {
                            Text(item.variantTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }

                        HStack {
                            Text("$\(item.price)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)

                            Spacer()

                            HStack(spacing: 12) {
                                Button(action: {
                                    if item.quantity > 1 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            quantityAnimation.toggle()
                                        }
                                        onQuantityChange(item.quantity - 1)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(item.quantity <= 1 ? .gray : .blue)
                                }
                                .disabled(item.quantity <= 1 || isDeletingItem)
                                .scaleEffect(quantityAnimation ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantityAnimation)

                                Text("\(itemQuantity)") /// updated here to put state item quantity
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 30)
                                    .scaleEffect(quantityAnimation ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantityAnimation)

                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        quantityAnimation.toggle()
                                    }
                                    onQuantityChange(item.quantity + 1)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .disabled(isDeletingItem)
                                .scaleEffect(quantityAnimation ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantityAnimation)
                            }
                        }
                    }

                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isDeletingItem)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .blur(radius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .scaleEffect(itemScale)
            .opacity(isDeletingItem ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isDeletingItem)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    itemScale = 1.0
                }
            }
            .confirmationDialog("Remove Item", isPresented: $showDeleteConfirmation) {
                Button("Remove", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        itemScale = 0.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onDelete()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to remove \(item.productTitle) from your cart?")
            }
        }
    }
#endif
