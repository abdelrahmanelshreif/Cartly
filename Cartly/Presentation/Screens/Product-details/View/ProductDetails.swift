//
//  ProductDetailsView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//

import Combine
import SwiftUI

struct ProductDetailsView: View {
    @StateObject private var viewModel: ProductDetailsViewModel
    let productId: Int64
    @StateObject private var wishlistViewModel: WishlistViewModel
    @State private var selectedImageIndex = 0
    @State private var selectedSize = ""
    @State private var selectedColor = ""
    @State private var quantity = 1

    init(productId: Int64) {
        self.productId = productId
        print("hiiiiiiiii2")

        _viewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveProductDetailsViewModel())
        print("hiiiiiiiii3")

        _wishlistViewModel = StateObject(
            wrappedValue: DIContainer.shared.resolveWishlistViewModel())
        print("hiiiiiiiii4")
    }

    var body: some View {
        NavigationView {
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
                                selectedSize: $selectedSize,
                                selectedColor: $selectedColor,
                                quantity: $quantity
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
        }
        .onAppear {
            viewModel.getProduct(for: productId)
//            wishlistViewModel.searchProductAtWishlist(
//                productId: String(productId))
        }
        .alert(isPresented: $wishlistViewModel.showWishlistAlert) {
            Alert(
                title: Text("Wishlist"),
                message: Text(wishlistViewModel.wishlistAlertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ProductDetailsContentView: View {
    @ObservedObject var viewModel: ProductDetailsViewModel
    @ObservedObject var wishlistViewModel: WishlistViewModel
    let product: ProductInformationEntity
    let reviews: [ReviewEntity]
    @State private var showAllReviews = false
    @Binding var selectedImageIndex: Int
    @Binding var selectedSize: String
    @Binding var selectedColor: String
    @Binding var quantity: Int

    private let maxPreviewReviews = 2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProductImageCarouselView(
                    images: product.images, selectedIndex: $selectedImageIndex)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("by \(product.vendor)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    HStack {
                        RatingView(rating: product.rating)
                        Text("(\(product.reviewCount) reviews)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        if product.originalPrice > product.price {
                            Text("$\(product.originalPrice, specifier: "%.2f")")
                                .font(.body)
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    if !product.availableSizes.isEmpty {
                        SizeSelectionView(
                            sizes: product.availableSizes,
                            selectedSize: $selectedSize
                        )
                    }

                    if !product.availableColors.isEmpty {
                        ColorSelectionView(
                            colors: product.availableColors,
                            selectedColor: $selectedColor
                        )
                    }

                    QuantitySelectionView(quantity: $quantity)

                    Divider()

                    ProductDescriptionView(description: product.description)

                    Divider()

                    // MARK: - Reviews Section

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Customer Reviews")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Spacer()

                            if reviews.count > maxPreviewReviews {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAllReviews.toggle()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text(
                                            showAllReviews
                                                ? "Show Less"
                                                : "Show All (\(reviews.count))")
                                        Image(
                                            systemName: showAllReviews
                                                ? "chevron.up" : "chevron.down"
                                        )
                                        .font(.caption2)
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(
                                showAllReviews
                                    ? reviews
                                    : Array(reviews.prefix(maxPreviewReviews)),
                                id: \.id
                            ) { review in
                                ReviewCardView(review: review)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity.combined(
                                                with: .move(edge: .top)),
                                            removal: .opacity.combined(
                                                with: .move(edge: .top))
                                        ))
                            }
                        }
                    }

                    Button(action: {
                        // TODO: Khalid Amr
                        // TODO: Add to Cart Functionality Will be Here ,....
                    }) {
                        Text("Add to Cart")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(!isValidSelection())

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    wishlistViewModel.toggleWishlist(product: product)
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
    }

    private func isValidSelection() -> Bool {
        let sizeValid = product.availableSizes.isEmpty || !selectedSize.isEmpty
        let colorValid =
            product.availableColors.isEmpty || !selectedColor.isEmpty
        return sizeValid && colorValid
    }
}

// MARK: - Preview

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        //        ProductDetailsView(productId: 8_135_647_985_847)
        ProductDetailsView(productId: 8135647985847)
        //        ProductDetailsView(productId:  8_135_647_232_183)
        //        ProductDetailsView(productId: 8_135_647_199_415)
    }
}
