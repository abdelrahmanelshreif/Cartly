import SwiftUI

struct ProductCardView: View {
    let product: ProductMapper
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var currencyConverter:CurrencyManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.product_Image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 140)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                    case .failure:
                        VStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("No Image")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.product_Title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(product.product_Type)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(product.product_Vendor)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Spacer(minLength: 4)

                HStack {
                    Text(currencyConverter.format(Double(product.product_Price) ?? 0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
        .onTapGesture {
            router.push(Route.productDetail(product.product_ID!))
        }
    }

    private func formatPrice(_ priceString: String) -> String {
        let cleanedString = priceString.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)

        if let price = Double(cleanedString) {
            return "$\(String(format: "%.2f", price))"
        }

        let pattern = #"\d+\.?\d*"#
        if let range = cleanedString.range(
            of: pattern, options: .regularExpression)
        {
            let numberString = String(cleanedString[range])
            if let price = Double(numberString) {
                return "$\(String(format: "%.2f", price))"
            }
        }

        return "Price N/A"
    }
}
