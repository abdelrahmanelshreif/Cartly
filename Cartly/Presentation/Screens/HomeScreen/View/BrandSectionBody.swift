import SwiftUI

struct BrandSectionBody: View {
    let brands: [BrandMapper]
    let onBrandTap: (Int64, String) -> Void

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 40) / 2

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(
                    rows: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 10
                ) {
                    ForEach(brands) { brand in
                        BrandCard(brand: brand, width: cardWidth)
                            .frame(height: geometry.size.height / 2 - 10)
                            .onTapGesture {
                                onBrandTap(brand.id, brand.brand_title)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: geometry.size.height)
            }
        }
    }
}
