//
//  MockReviews.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import Foundation

struct MockReviewData {
    static let productReviews: [ReviewEntity] = [
        ReviewEntity(
            reviewerName: "Sarah M.",
            reviewerAvatar: "person.circle.fill",
            rating: 5,
            title: "Amazing product!",
            comment: "This product exceeded my expectations. Great quality and fast shipping. Would definitely recommend to anyone looking for this type of item.",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "John D.",
            reviewerAvatar: "person.circle.fill",
            rating: 4,
            title: "Very satisfied",
            comment: "Good value for money. The build quality is solid and it works exactly as described. Only minor complaint is the packaging could be better.",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "Emily R.",
            reviewerAvatar: "person.circle.fill",
            rating: 5,
            title: "Perfect!",
            comment: "Exactly what I needed. The product arrived quickly and was exactly as shown in the pictures. Will buy from this seller again.",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "Mike C.",
            reviewerAvatar: "person.circle.fill",
            rating: 3,
            title: "It's okay",
            comment: "The product is decent but not outstanding. It does what it's supposed to do, but I was hoping for a bit more based on the description.",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "Lisa T.",
            reviewerAvatar: "person.circle.fill",
            rating: 4,
            title: "Good purchase",
            comment: "Happy with this purchase. Good quality and reasonable price. Delivery was faster than expected which was a nice bonus.",
            date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "David K.",
            reviewerAvatar: "person.circle.fill",
            rating: 5,
            title: "Highly recommend",
            comment: "Outstanding product! The attention to detail is impressive and the customer service was excellent. Will definitely shop here again.",
            date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
        ),
        ReviewEntity(
            reviewerName: "Anna B.",
            reviewerAvatar: "person.circle.fill",
            rating: 4,
            title: "Great find",
            comment: "Really pleased with this purchase. The product is well-made and functions perfectly. Great addition to my collection.",
            date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date()
        )
    ]
}
