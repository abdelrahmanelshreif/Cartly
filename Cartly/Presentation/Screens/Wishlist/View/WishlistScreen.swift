//
//  WishlistScreen.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

import SwiftUI

struct WishlistScreen: View {
    @StateObject var wishlistViewModel: WishlistViewModel

    init() {
        self._wishlistViewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveWishlistViewModel())
    }

    var body: some View {
        Group {
            if wishlistViewModel.isAuthorized {
                if wishlistViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if wishlistViewModel.userWishlist.isEmpty {
                    EmptyWishlistView()
                } else {
                    WishlistContentView(
                        isLoading: $wishlistViewModel.isLoading,
                        viewModel: wishlistViewModel,
                        wishlistProducts: wishlistViewModel.userWishlist)
                }
            } else {
                GuestModeView()
            }
        }
        .navigationTitle("My Wishlist")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            wishlistViewModel.checkAuthorization()
            if wishlistViewModel.isAuthorized {
                wishlistViewModel.getUserWishlist()
            }
        }
    }
}

struct WishlistContentView: View {
    @Binding var isLoading: Bool
    @StateObject var viewModel: WishlistViewModel
    let wishlistProducts: [WishlistProduct]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.userWishlist) { product in
                    WishlistItemView(
                        isLoading: $isLoading,
                        product: product,
                        onRemove: {
                            viewModel.removeProductAtWishlist(
                                productId: product.productId)
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct WishlistItemView: View {
    @Binding var isLoading: Bool
    let product: WishlistProduct
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let imgUrl = product.image {
                    AsyncImage(url: URL(string: imgUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .empty:
                            ProgressView()
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity)
                        case .failure(_):
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12.0))

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text("$\(product.price ?? 0.0, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                Text("by \(product.vendor ?? "Generic")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EmptyWishlistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .fontWeight(.semibold)
                .foregroundStyle(.gray.opacity(0.5))

            Text("Your wishlist is empty")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("Start adding items you love!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GuestModeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 80))
                .fontWeight(.semibold)
                .foregroundStyle(.red.opacity(0.9))

            Text("You should login or register to have your own wishlist...")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        WishlistScreen()
    }
}
