//
//  RatingView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}




