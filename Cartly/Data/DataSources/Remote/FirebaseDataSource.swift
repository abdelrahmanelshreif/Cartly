//
//  FirebaseDataSource.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 6/6/25.
//

import Combine
import Foundation

protocol FirebaseDataSourceProtocol {
    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<
        [WishlistProduct]?, Error
    >
    func addWishlistProductForUser(
        whoseId id: String, withProduct product: WishlistProduct
    ) -> AnyPublisher<Void, Error>
    func removeWishlistProductForUser(
        whoseId id: String, withProduct productId: String
    ) -> AnyPublisher<Void, Error>
    func isProductInWishlist(withProduct productId: String, forUser id: String)
        -> AnyPublisher<Bool, Error>
}

class FirebaseDataSource: FirebaseDataSourceProtocol {

    private let firebaseServices: FirebaseServiceProtocol

    init(firebaseServices: FirebaseServiceProtocol) {
        self.firebaseServices = firebaseServices
    }

    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<
        [WishlistProduct]?, any Error
    > {
        return firebaseServices.getUserWishlist(userId: id)
    }

    func addWishlistProductForUser(
        whoseId id: String, withProduct product: WishlistProduct
    ) -> AnyPublisher<Void, any Error> {
        return firebaseServices.addProductToWishlist(
            userId: id, product: product)
    }

    func removeWishlistProductForUser(
        whoseId id: String, withProduct productId: String
    ) -> AnyPublisher<Void, any Error> {
        return firebaseServices.removeProductFromWishlist(
            userId: id, productId: productId)
    }

    func isProductInWishlist(withProduct productId: String, forUser id: String)
        -> AnyPublisher<Bool, any Error>
    {
        return firebaseServices.isProductInWishlist(
            userId: id, productId: productId)
    }

}
