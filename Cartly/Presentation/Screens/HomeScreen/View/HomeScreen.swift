import SwiftUI
struct HomeScreen: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var router: AppRouter

    init() {
        _viewModel = StateObject(wrappedValue:
            HomeViewModel(
                getBrandUseCase: GetBrandsUseCase(
                    repository: RepositoryImpl(remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()), firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
                    )
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HomeToolbar(cartState: viewModel.cartState)

            Ads()

            Spacer()

            SectionHeader(headerText: "Brands")
                .padding(.horizontal)
                .padding(.bottom, 4)	

            Spacer()

            Group {
                switch viewModel.brandState {
                case .loading:
                    ProgressView("Loading brands...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case let .success(brands):
                    BrandSectionBody(brands: brands) { brandId, brandTitle in
                        router.push(Route.Products(brandId, brandTitle))
                    }
                    
                case .failure(_):
                    Text("Fail")
                }
            }

            Spacer()
        }
        .onAppear {
            viewModel.loadBrands()
            viewModel.loadCartItemCount()
        }
        .background(Color(.systemGroupedBackground))
    }
}
