import SwiftUI

struct ProductScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProductsViewModel
    let brandId: Int64
    let brandTitle: String
    init(brandId: Int64, brandTitle: String) {
        self.brandId = brandId
        self.brandTitle = brandTitle
        _viewModel = StateObject(wrappedValue: ProductsViewModel(useCase: GetProductsForBrandId(repository: RepositoryImpl(remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()), firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())))))
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.productState {
                case .loading:
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case let .success(products):
                    if products.isEmpty {
                        EmptyProductsView()
                    } else {
                        ProductSectionBody(products: products) { productId in
                            print("hiiiiiiiii1")
                            router.push(.productDetail(productId))
                        }
                    }

                case let .failure(error):
                    ProductsErrorView(
                        title: "Failed to load products",
                        message: error,
                        retryAction: {
                            viewModel.loadProducts(brandId: brandId)
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("\(brandTitle)")
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CartButton(cartState: viewModel.cartState)
            }
        }
        .onAppear {
            viewModel.loadProducts(brandId: brandId)
            viewModel.loadCartItemCount()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct EmptyProductsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Products Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This brand doesn't have any products available at the moment.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct ProductsErrorView: View {
    let title: String
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#if false
var body: some View {
    NavigationStack {
        ScrollView {
            ProductsToolbar(cartState: viewModel.cartState)
            Spacer()
            
            switch viewModel.productState {
            case .loading:
                ProgressView()
                
            case let .success(products):
                ProductSectionBody(products: products) { productId in
                    selectedProductId = productId
                }
                
            case let .failure(message):
                Text(message)
            }
        }
        .onAppear {
            viewModel.loadCartItemCount()
            viewModel.loadProducts(for: brandId)
        }
        
        .navigationDestination(
            isPresented: Binding<Bool>(
                get: { selectedProductId != nil },
                set: { if !$0 { selectedProductId = nil } }
            )
        ) {
            if let productId = selectedProductId {
                ProductDetailsView(
                    productId: Int(productId),
                    getProductUseCase: GetProductDetailsUseCase(
                        repository: RepositoryImpl(
                            remoteDataSource: RemoteDataSourceImpl(
                                networkService: AlamofireService()
                            )
                        )
                    )
                )
            }
        }
    }
}
#endif
