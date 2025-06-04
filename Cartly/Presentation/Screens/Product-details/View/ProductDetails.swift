//
//  ProductDetailsView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//

import SwiftUI

struct ProductDetailsView: View {
    @StateObject private var viewModel: ProductDetailsViewModel
    let productId: Int

    @State private var selectedImageIndex = 0
    @State private var selectedSize = ""
    @State private var selectedColor = ""
    @State private var quantity = 1

  
    init(productId: Int, getProductUseCase: GetProductDetailsUseCaseProtocol) {
        self.productId = productId
        self._viewModel = StateObject(
            wrappedValue: ProductDetailsViewModel(
                getProductUseCase: getProductUseCase))
    }

    var body: some View {
        NavigationView {
            Group {
                VStack {
                    if let resultState = viewModel.resultState {
                        switch resultState {
                        case .success(let product):
                            ProductDetailsContentView(
                                product: product,
                                selectedImageIndex: $selectedImageIndex,
                                selectedSize: $selectedSize,
                                selectedColor: $selectedColor,
                                quantity: $quantity
                            )
                        case .failure(let error):
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
        }
    }
}

struct ProductDetailsContentView: View {
    let product: ProductInformationEntity
    let reviews = MockReviewData.productReviews
    @Binding var selectedImageIndex: Int
    @Binding var selectedSize: String
    @Binding var selectedColor: String
    @Binding var quantity: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProductImageCarouselView(
                    images: product.images,
                    selectedIndex: $selectedImageIndex
                )

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("by \(product.vendor)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Customer Reviews")
                            .font(.title3)
                            .fontWeight(.semibold)

                        LazyVStack(spacing: 12) {
                            ForEach(reviews, id: \.id) { review in
                                ReviewCardView(review: review)
                            }
                        }
                    }

                    Button(action: {
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

        ProductDetailsView(
            productId: 8_135_647_101_111,
            getProductUseCase: GetProductDetailsUseCase(
                repository: RepositoryImpl(
                    remoteDataSource: RemoteDataSourceImpl(
                        networkService: AlamofireService())))
        )
    }
}
