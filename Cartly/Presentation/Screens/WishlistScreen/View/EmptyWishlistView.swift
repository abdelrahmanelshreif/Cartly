//
//  EmptyWishlistView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//
import SwiftUI

struct EmptyWishlistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .fontWeight(.semibold)
                .foregroundStyle(.gray.opacity(0.5))

            Text("Your wishlist is empty")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("Start adding items you love!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
