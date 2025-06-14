//
//  CartScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 08/06/2025.
//
#if true
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
                deleteCartItemUseCase: DeleteCartItemUseCase(repository: repository)
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
            .navigationTitle("MY CART")
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

        @State private var showDeleteConfirmation = false
        @State private var itemScale: CGFloat = 1.0
        @State private var quantityAnimation: Bool = false

        var body: some View {
            HStack(alignment: .center, spacing: 16) {
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

                            Text("\(item.quantity)")
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
#if false
    import SwiftUI

    struct CartScreen: View {
        @StateObject private var viewModel: CartViewModel
        @EnvironmentObject private var router: AppRouter

        init() {
            let repository = RepositoryImpl(
                remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
            )

            _viewModel = StateObject(wrappedValue: CartViewModel(
                getCustomerCartUseCase: GetCustomerCartUseCase(repository: repository),
                deleteCartItemUseCase: DeleteCartItemUseCase(repository: repository)
            ))
        }

        var body: some View {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading cart...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isCartEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.cartItems, id: \.orderID) { cartMapper in
                                VStack(spacing: 12) {
                                    ForEach(cartMapper.itemsMapper, id: \.itemId) { item in
                                        CartItemView(
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
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(viewModel.totalPrice, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding([.horizontal, .top])

                    Button(action: {
                        /// navigate to map or payment screen
                        print(viewModel.cartItems.first?.hasAddress ?? false)

                        if !viewModel.isCartEmpty {
                            router.push(Route.OrderCompletingScreen(viewModel.cartItems.first!))
                        }
                    }) {
                        Text("Checkout (\(viewModel.totalItemsCount) items)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isCartEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isCartEmpty || viewModel.isDeletingItem)
                    .padding()
                }
            }
            .navigationTitle("CART")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadCustomerCart()
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
            .overlay(
                Group {
                    if viewModel.isDeletingItem {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Removing item...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
            )
        }
    }

    struct CartItemView: View {
        let item: ItemsMapper
        let isDeletingItem: Bool
        let onQuantityChange: (Int) -> Void
        let onDelete: () -> Void

        @State private var showDeleteConfirmation = false

        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                /// هنشيل ده قدام بالصوره الاصليه اما نعمل اللوجيك بتاعها
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productTitle)
                        .font(.headline)
                        .lineLimit(2)

                    if !item.variantTitle.isEmpty {
                        Text(item.variantTitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Text("$\(item.price)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Button(action: {
                            if item.quantity > 1 {
                                onQuantityChange(item.quantity - 1)
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(item.quantity <= 1 ? .gray : .blue)
                        }
                        .buttonStyle(.plain)
                        .disabled(item.quantity <= 1 || isDeletingItem)

                        Text("\(item.quantity)")
                            .padding(.horizontal, 8)
                            .font(.body)
                            .fontWeight(.medium)

                        Button(action: {
                            onQuantityChange(item.quantity + 1)
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDeletingItem)
                    }
                    .font(.title3)
                    .padding(.top, 4)
                }

                Spacer()

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .disabled(isDeletingItem)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .opacity(isDeletingItem ? 0.6 : 1.0)
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
        init() {
            _viewModel = StateObject(wrappedValue: CartViewModel(getCustomerCartUseCase: GetCustomerCartUseCase(repository: RepositoryImpl(remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()), firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())))))
        }

        var body: some View {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading cart...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isCartEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.cartItems, id: \.orderID) { cartMapper in
                                VStack(spacing: 12) {
                                    ForEach(cartMapper.itemsMapper, id: \.itemId) { item in
                                        CartItemView(
                                            item: item,
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
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(viewModel.totalPrice, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding([.horizontal, .top])

                    Button(action: {
                        /// navigate to map or payment screen
                        print(viewModel.cartItems.first?.hasAddress ?? false)

                        if !viewModel.isCartEmpty {
                            router.push(Route.OrderCompletingScreen(viewModel.cartItems.first!))
                        }
                    }) {
                        Text("Checkout (\(viewModel.totalItemsCount) items)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("CART")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadCustomerCart()
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
    }

    struct CartItemView: View {
        let item: ItemsMapper
        let onQuantityChange: (Int) -> Void
        let onDelete: () -> Void

        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                /// هنشيل ده قدام بالصوره الاصليه اما نعمل اللوجيك بتاعها
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productTitle)
                        .font(.headline)
                        .lineLimit(2)

                    if !item.variantTitle.isEmpty {
                        Text(item.variantTitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Text("$\(item.price)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Button(action: {
                            if item.quantity > 1 {
                                onQuantityChange(item.quantity - 1)
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(item.quantity <= 1 ? .gray : .blue)
                        }
                        .buttonStyle(.plain)
                        .disabled(item.quantity <= 1)

                        Text("\(item.quantity)")
                            .padding(.horizontal, 8)
                            .font(.body)
                            .fontWeight(.medium)

                        Button(action: {
                            onQuantityChange(item.quantity + 1)
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.title3)
                    .padding(.top, 4)
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }
#endif
