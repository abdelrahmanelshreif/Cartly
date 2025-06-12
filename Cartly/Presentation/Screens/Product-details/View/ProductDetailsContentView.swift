//
//  ProductDetailsContentView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//

import SwiftUI

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
    @Binding var showLoginAlert: Bool

    private let maxPreviewReviews = 2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProductImageCarouselView(
                    images: product.images,
                    selectedIndex: $selectedImageIndex
                )

                VStack(alignment: .leading, spacing: 12) {
                    // Product Name and Vendor
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
                        if let variantPrice = viewModel.variantPrice {
                            Text("$\(variantPrice, specifier: "%.2f")")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        } else {
                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }

                        if product.originalPrice > (viewModel.variantPrice ?? product.price) {
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

                    if viewModel.showQuantitySelector {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if viewModel.isVariantAvailable {
                                    Text("Available:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text("\(viewModel.availableStock) in stock")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(viewModel.availableStock > 0 ? .green : .red)

                                    // Show max quantity limit info
                                    Text("(Max: \(viewModel.maxQuantity))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Currently Unavailable")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)

                            if viewModel.isVariantAvailable && viewModel.availableStock > 0 {
                                Text("Quantity")
                                    .font(.headline)

                                HStack {
                                    Button(action: {
                                        viewModel.decrementQuantity()
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(
                                                viewModel.canDecrementQuantity() ? .blue : .gray
                                            )
                                    }
                                    .disabled(!viewModel.canDecrementQuantity())

                                    Text("\(viewModel.quantity)")
                                        .font(.body)
                                        .frame(minWidth: 40)

                                    Button(action: {
                                        viewModel.incrementQuantity()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(
                                                viewModel.canIncrementQuantity() ? .blue : .gray
                                            )
                                    }
                                    .disabled(!viewModel.canIncrementQuantity())

                                    Spacer()
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.showQuantitySelector)
                    }

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
                                                : "Show All (\(reviews.count))"
                                        )
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
                        handleAddToCart()
                    }) {
                        HStack {
                            if viewModel.isAddingToCart {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Adding...")
                            } else {
                                Text("Add to Cart")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.isAddToCartEnabled && !viewModel.isAddingToCart ? Color.blue : Color.gray
                        )
                        .cornerRadius(10)
                    }
                    .disabled(!viewModel.isAddToCartEnabled || viewModel.isAddingToCart)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
    }

    private func handleAddToCart() {
        wishlistViewModel.checkAuthorization()
        if wishlistViewModel.isAuthorized {
            viewModel.addToCart()
        } else {
            showLoginAlert = true
        }
    }
}

#if false
    import SwiftUI

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
        @Binding var showLoginAlert: Bool

        private let maxPreviewReviews = 2

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ProductImageCarouselView(
                        images: product.images,
                        selectedIndex: $selectedImageIndex
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        // Product Name and Vendor
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
                            if let variantPrice = viewModel.variantPrice {
                                Text("$\(variantPrice, specifier: "%.2f")")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            } else {
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }

                            if product.originalPrice > (viewModel.variantPrice ?? product.price) {
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

                        if viewModel.showQuantitySelector {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    if viewModel.isVariantAvailable {
                                        Text("Available:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Text("\(viewModel.availableStock) in stock")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(viewModel.availableStock > 0 ? .green : .red)

                                        Text("(Max: \(viewModel.maxQuantity))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                    } else {
                                        Text("Currently Unavailable")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 4)

                                if viewModel.isVariantAvailable && viewModel.availableStock > 0 {
                                    Text("Quantity")
                                        .font(.headline)

                                    HStack {
                                        Button(action: {
                                            viewModel.decrementQuantity()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(
                                                    viewModel.canDecrementQuantity() ? .blue : .gray
                                                )
                                        }
                                        .disabled(!viewModel.canDecrementQuantity())

                                        Text("\(viewModel.quantity)")
                                            .font(.body)
                                            .frame(minWidth: 40)

                                        Button(action: {
                                            viewModel.incrementQuantity()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(
                                                    viewModel.canIncrementQuantity() ? .blue : .gray
                                                )
                                        }
                                        .disabled(!viewModel.canIncrementQuantity())

                                        Spacer()
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showQuantitySelector)
                        }

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
                                                    : "Show All (\(reviews.count))"
                                            )
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
                            handleAddToCart()
                        }) {
                            Text("Add to Cart")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.isAddToCartEnabled ? Color.blue : Color.gray
                                )
                                .cornerRadius(10)
                        }
                        .disabled(!viewModel.isAddToCartEnabled || viewModel.isAddingToCart)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
        }

        private func handleAddToCart() {
            wishlistViewModel.checkAuthorization()
            if wishlistViewModel.isAuthorized {
                viewModel.addToCart()
            } else {
                showLoginAlert = true
            }
        }
    }
#endif
