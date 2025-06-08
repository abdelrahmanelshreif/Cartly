import SwiftUI

struct CardView: View {
    
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.thumbnail)) {
                $0.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(10)

            Text(product.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.horizontal, 8)

            Text(product.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
                .padding([.horizontal, .bottom], 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 4)
        .padding(4)
    }
}
