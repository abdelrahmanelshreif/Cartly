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
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
