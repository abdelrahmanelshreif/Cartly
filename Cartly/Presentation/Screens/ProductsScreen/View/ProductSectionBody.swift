import SwiftUI

struct ProductSectionBody: View {
    let products: [ProductMapper]
    let onProductTap: (Int64) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(products) { product in
                    ProductCardView(product: product)
                        .onTapGesture {
                            if let product_ID = product.product_ID {
                                onProductTap(product_ID)
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
