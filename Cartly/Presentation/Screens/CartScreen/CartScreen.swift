//
//  CartScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 08/06/2025.
//

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
struct CartItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let size: String
    let color: String
    let price: Double
    var quantity: Int
    
    static let sampleData: [CartItem] = [
           .init(imageName: "backpack", title: "Adidas Classic Backpack", size: "OS", color: "Black", price: 70, quantity: 1),
        .init(imageName: "stan_smith", title: "Adidas Kid's Stan Smith", size: "1", color: "White", price: 90, quantity: 4),
        .init(imageName: "boots", title: "Dr. Martens 1460Z Cherry", size: "3", color: "Red", price: 249, quantity: 1)
    ]
}
#Preview {
    CartScreen()
}

/*
 {
     HStack {
         Text("Order #\(cartMapper.orderID)")
             .font(.headline)
             .foregroundColor(.primary)
         Spacer()
         Text(cartMapper.orderStatus.capitalized)
             .font(.caption)
             .padding(.horizontal, 8)
             .padding(.vertical, 4)
             .background(Color.blue.opacity(0.1))
             .foregroundColor(.blue)
             .cornerRadius(8)
     }
     .padding(.horizontal)
 }
 */
#if false
    import SwiftUI

    struct CartScreen: View {
        @State private var cartItems: [CartItem] = CartItem.sampleData
        @State private var total: Double = 0.0

        var body: some View {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($cartItems) { $item in
                            CartItemView(item: $item, onDelete: {
                                withAnimation {
                                    cartItems.removeAll { $0.id == item.id }
                                }
                            })
                        }
                    }
                    .padding()
                }

                Divider()

                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("$\(cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding([.horizontal, .top])

                Button(action: {
                    // Checkout action
                }) {
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Cart")
        }
    }

    struct CartItemView: View {
        @Binding var item: CartItem
        let onDelete: () -> Void

        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                Image(item.imageName)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    Text("\(item.size) / \(item.color)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.subheadline)

                    HStack {
                        Button(action: {
                            if item.quantity > 1 { item.quantity -= 1 }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.plain)

                        Text("\(item.quantity)")
                            .padding(.horizontal, 8)

                        Button(action: {
                            item.quantity += 1
                        }) {
                            Image(systemName: "plus.circle")
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
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
    }

    struct CartItem: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
        let size: String
        let color: String
        let price: Double
        var quantity: Int

        static let sampleData: [CartItem] = [
            .init(imageName: "backpack", title: "Adidas Classic Backpack", size: "OS", color: "Black", price: 70, quantity: 1),
            .init(imageName: "stan_smith", title: "Adidas Kid's Stan Smith", size: "1", color: "White", price: 90, quantity: 4),
            .init(imageName: "boots", title: "Dr. Martens 1460Z Cherry", size: "3", color: "Red", price: 249, quantity: 1),
        ]
    }
#endif
