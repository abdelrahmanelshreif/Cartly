//
//  WishlistScreen.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

import SwiftUI

struct WishlistScreen: View {
    @EnvironmentObject var router: AppRouter
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
                LoggedOutView{
                    router.setRoot(.authentication)
                }
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
        .background(Color(.systemGroupedBackground))
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




