//
//  ReviewComponent.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 4/6/25.
//
import SwiftUI

struct ReviewCardView: View {
    let review: ReviewEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: review.reviewerAvatar)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(review.reviewerName)
                    .font(.system(size: 16, weight: .medium))

                Text(review.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .leading , spacing: 2) {
                HStack {
                    ForEach(1...5, id: \.self) {
                        star in
                        Image(
                            systemName: star <= review.rating
                                ? "star.fill" : "star"
                        )
                        .foregroundColor(
                            star <= review.rating ? .yellow : .gray.opacity(0.3)
                        )
                        .font(.system(size: 14))
                    }
                }
                Text(review.title)
                    .font(.system(size: 16, weight: .semibold))

                Text(review.comment)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

        }
    }

}
