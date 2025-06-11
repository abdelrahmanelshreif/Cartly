//
//  WishlistItemView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//

import SwiftUI

struct WishlistItemView: View {
    @Binding var isLoading: Bool
    let product: WishlistProduct
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let imgUrl = product.image {
                    AsyncImage(url: URL(string: imgUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .empty:
                            ProgressView()
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity)
                        case .failure(_):
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12.0))

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text("$\(product.price ?? 0.0, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                Text("by \(product.vendor ?? "Generic")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .disabled(isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
