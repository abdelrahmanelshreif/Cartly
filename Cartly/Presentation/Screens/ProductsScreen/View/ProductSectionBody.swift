import SwiftUI

struct ProductSectionBody: View {
    let products: [ProductMapper]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(products) { product in
                    ProductCardView(product: product)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
