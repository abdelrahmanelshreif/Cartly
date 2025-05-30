import SwiftUI

struct ProductsListView: View {
    @StateObject var viewModel: ProductsViewModel
    let collectionID: Int

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")

            case let .failure(error):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Failed to load products")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()

            case let .success(products):
                List(products, id: \.id) { product in
                    VStack(alignment: .leading) {
                        Text(product.title ?? "Untitled")
                            .font(.headline)
                        Text(product.vendor ?? "Unknown Vendor")
                            .font(.subheadline)
                    }
                }
            }
        }
        .onAppear {
            viewModel.load(for: collectionID) 
        }
    }
}
