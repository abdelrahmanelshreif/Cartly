import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue:
            HomeViewModel(
                getBrandUseCase: GetBrandsUseCase(
                    repository: RepositoryImpl(
                        remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService())
                    )
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            /// 1
            HomeToolbar(cartState: viewModel.cartState)
            /// 2
            Ads()
            Spacer()

            /// 3
            SectionHeader(headerText: "Brands")
                .padding(.horizontal)
                .padding(.bottom,  4)
            Spacer()
            /// 4
            Group{
                switch viewModel.brandState{
                case .loading:
                    ProgressView()
                case .success(let brands):
                    BrandSectionBody(brands: brands)
                case .failure(let error):
                    Text(error)
                }
            }
            Spacer()
            .onAppear {
                viewModel.loadBrands()
                viewModel.loadCartItemCount()
            }
        }
    }
}
