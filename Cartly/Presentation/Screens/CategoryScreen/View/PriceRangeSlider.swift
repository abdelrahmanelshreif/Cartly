import Combine
import SwiftUI
struct PriceRangeSlider: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    let priceRange: ClosedRange<Double>
    @State private var isAdjusting = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Price Range")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Drag to adjust range")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(Int(minPrice)) - $\(Int(maxPrice))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                    Text("Selected Range")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.7), Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(0, (maxPrice - minPrice) / (priceRange.upperBound - priceRange.lowerBound) * geometry.size.width),
                            height: 8
                        )
                        .offset(x: (minPrice - priceRange.lowerBound) / (priceRange.upperBound - priceRange.lowerBound) * geometry.size.width)

                    Circle()
                        .fill(Color.blue)
                        .frame(width: isAdjusting ? 24 : 20, height: isAdjusting ? 24 : 20)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: (minPrice - priceRange.lowerBound) / (priceRange.upperBound - priceRange.lowerBound) * geometry.size.width - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isAdjusting = true
                                    let newValue = priceRange.lowerBound + (value.location.x / geometry.size.width) * (priceRange.upperBound - priceRange.lowerBound)
                                    minPrice = max(priceRange.lowerBound, min(newValue, maxPrice - 1))
                                }
                                .onEnded { _ in
                                    isAdjusting = false
                                }
                        )

                    Circle()
                        .fill(Color.blue)
                        .frame(width: isAdjusting ? 24 : 20, height: isAdjusting ? 24 : 20)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: (maxPrice - priceRange.lowerBound) / (priceRange.upperBound - priceRange.lowerBound) * geometry.size.width - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isAdjusting = true
                                    let newValue = priceRange.lowerBound + (value.location.x / geometry.size.width) * (priceRange.upperBound - priceRange.lowerBound)
                                    maxPrice = min(priceRange.upperBound, max(newValue, minPrice + 1))
                                }
                                .onEnded { _ in
                                    isAdjusting = false
                                }
                        )
                }
            }
            .frame(height: 40)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAdjusting)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
