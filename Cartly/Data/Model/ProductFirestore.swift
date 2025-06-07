//
//  ProductFirestore.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 4/6/25.
//

import Foundation
import FirebaseFirestore

struct WishlistProduct: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let productId: String
    let title: String
    let bodyHtml: String
    let vendor: String?
    let productType: String
    let status: String?
    let image: String?
    
    
    static func == (lhs: WishlistProduct, rhs: WishlistProduct) -> Bool {
        return lhs.id == rhs.id
    }
    
}

struct Wishlist: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    var products: [WishlistProduct]
    
    init(userId: String, products: [WishlistProduct] = []) {
        self.userId = userId
        self.products = products
    }
    
    mutating func addProduct(_ product: WishlistProduct) {
        if !products.contains(product) {
            products.append(product)
        }
    }
    
    mutating func removeProduct(_ product: WishlistProduct) {
        products.removeAll { $0.id == product.id }
    }
}
