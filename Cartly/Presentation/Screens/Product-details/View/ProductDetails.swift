//
//  ProductDetailsView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//

import Combine
import SwiftUI

struct ProductDetailsView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProductDetailsViewModel
    let productId: Int64
    @StateObject private var wishlistViewModel: WishlistViewModel
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    @State private var showLoginAlert = false
    @State private var showLoginView = false
    private var cartVarient:Int64?
    private var isCartSource:Bool?

    init(productId: Int64) {
        self.productId = productId
        _viewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveProductDetailsViewModel())
        _wishlistViewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveWishlistViewModel())
    }
    
    init(productId: Int64, isFromCart:Bool , varientId:Int64) {
        self.productId = productId
        _viewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveProductDetailsViewModel())
        _wishlistViewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveWishlistViewModel())
        isCartSource = isFromCart
        cartVarient = varientId
    }

    var body: some View {
           Group {
               VStack {
                   if let resultState = viewModel.resultState {
                       switch resultState {
                       case let .success(product):
                           ProductDetailsContentView(
                               viewModel: viewModel,
                               wishlistViewModel: wishlistViewModel,
                               product: product,
                               reviews: MockReviewData.productReviews,
                               selectedImageIndex: $selectedImageIndex,
                               selectedSize: $viewModel.selectedSize,
                               selectedColor: $viewModel.selectedColor,
                               quantity: $viewModel.quantity,
                               showLoginAlert: $showLoginAlert
                           )
                    case let .failure(error):
                        ErrorView(error: error) {
                            viewModel.getProduct(for: productId)
                        }
                    case .loading:
                        ProgressView()
                    }
                } else {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    handleWishlistAction()
                }) {
                    Image(
                        systemName: wishlistViewModel.atWishlist
                            ? "heart.fill" : "heart"
                    )
                    .foregroundColor(
                        wishlistViewModel.atWishlist ? .blue : .blue)
                }
            }
        }
        .onAppear {
            if let  src = isCartSource , let vId = cartVarient {
                viewModel.getProduct(for: productId, sourceisCart: src , cartVarientId: vId)
            }else{
                viewModel.getProduct(for: productId)
            }
            wishlistViewModel.checkAuthorization()
            if wishlistViewModel.isAuthorized {
                wishlistViewModel.searchProductAtWishlist(
                    productId: String(productId))
            }
        }
        // Wishlist login alert
        .alert("Login Required", isPresented: $showLoginAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Login") {
                router.setRoot(.authentication)
            }
        } message: {
            Text(wishlistViewModel.wishlistAlertMessage)
        }
        // Wishlist success/error alert
        .alert("Wishlist", isPresented: $wishlistViewModel.showWishlistAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(wishlistViewModel.wishlistAlertMessage)
        }
        // Cart alert from viewModel
        .alert("Cart", isPresented: $viewModel.triggerAlert) {

            Button("OK", role: .cancel) {}

        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private func handleWishlistAction() {
        wishlistViewModel.checkAuthorization()
        if wishlistViewModel.isAuthorized {
            if case .success(let product) = viewModel.resultState {
                wishlistViewModel.toggleWishlist(product: product)
            }
        } else {
            showLoginAlert = true
        }
    }
}

