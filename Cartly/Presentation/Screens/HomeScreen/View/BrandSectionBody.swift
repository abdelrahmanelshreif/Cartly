import SwiftUI

struct BrandSectionBody: View {
    let brands: [BrandMapper]
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 40) / 2 // Two columns with padding
            
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
                            .frame(height: geometry.size.height / 2 - 10) // Half of available height
                            .onTapGesture {
                                print(brand.brand_title)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: geometry.size.height) // Take full available height
            }
        }
    }
}
