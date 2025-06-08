import Combine
import SwiftUI

struct ProductTypeSegmentControl: View {
    @Binding var selectedType: ProductType
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Type")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProductType.allCases, id: \.self) { type in
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedType = type
                            }
                        }) {
                            VStack(spacing: 8) {
                                if type == .all {
                                    Image(systemName: "square.grid.2x2")
                                        .font(.system(size: 20, weight: .medium))
                                } else {
                                    Text(type.icon)
                                        .font(.system(size: 24))
                                }

                                Text(type == .all ? "All" : type.rawValue.capitalized)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(selectedType == type ? .white : .primary)
                            .frame(width: 80, height: 80)
                            .background(
                                Group {
                                    if selectedType == type {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.blue)
                                            .matchedGeometryEffect(id: "selectedType", in: animation)
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemGray6))
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedType == type ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
