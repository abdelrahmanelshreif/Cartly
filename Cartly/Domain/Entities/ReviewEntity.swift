//
//  ReviewEntity.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import Foundation

struct ReviewEntity: Identifiable {
    let id = UUID()
    let reviewerName: String
    let reviewerAvatar: String
    let rating: Int
    let title: String
    let comment: String
    let date: Date
}
