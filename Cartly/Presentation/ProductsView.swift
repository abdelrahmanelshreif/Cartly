//import SwiftUI
//
//struct ProductsListView: View {
//    @StateObject var viewModel: HomeViewModel
//
//    var body: some View {
//        NavigationView {
//            switch viewModel.state {
//            case .loading:
//                ProgressView("Loading...")
//
//            case let .failure(errorMessage):
//                VStack(spacing: 12) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .font(.largeTitle)
//                        .foregroundColor(.orange)
//                    Text("Failed to load products")
//                        .font(.headline)
//                    Text(errorMessage)
//                        .font(.caption)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//                .padding()
//
//            case let .success(brands):
////                List(brands, id: \.id) { brand in
//                    VStack(alignment: .leading) {
//                        Text(brand.title)
//                            .font(.headline)
//                        Text(brand.subtitle) // Replace with correct property
//                            .font(.subheadline)
//                    }
//                }
//            }
//        }
//        .onAppear {
//            viewModel.loadBrands()
//        }
//        .navigationTitle("Brands")
//
//    }
//}
