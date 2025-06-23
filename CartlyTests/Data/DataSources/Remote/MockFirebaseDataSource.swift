//
//  MockFirebaseDataSource.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 23/6/25.
//

import Combine
import Foundation

@testable import Cartly

class MockFirebaseDataSource: FirebaseDataSourceProtocol {
    // Get Wishlist Products
    var getWishlistProductsCallCount = 0
    var lastGetWishlistUserId: String?
    let getWishlistProductsSubject = PassthroughSubject<
        [WishlistProduct]?, Error
    >()

    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<
        [WishlistProduct]?, Error
    > {
        getWishlistProductsCallCount += 1
        lastGetWishlistUserId = id
        return getWishlistProductsSubject.eraseToAnyPublisher()
    }

    // Add Wishlist Product
    var addWishlistProductCallCount = 0
    var lastAddWishlistUserId: String?
    var lastAddedWishlistProduct: WishlistProduct?
    let addWishlistProductSubject = PassthroughSubject<Void, Error>()

    func addWishlistProductForUser(
        whoseId id: String, withProduct product: WishlistProduct
    ) -> AnyPublisher<Void, Error> {
        addWishlistProductCallCount += 1
        lastAddWishlistUserId = id
        lastAddedWishlistProduct = product
        return addWishlistProductSubject.eraseToAnyPublisher()
    }

    // Remove Wishlist Product
    var removeWishlistProductCallCount = 0
    var lastRemoveWishlistUserId: String?
    var lastRemovedWishlistProductId: String?
    let removeWishlistProductSubject = PassthroughSubject<Void, Error>()

    func removeWishlistProductForUser(
        whoseId id: String, withProduct productId: String
    ) -> AnyPublisher<Void, Error> {
        removeWishlistProductCallCount += 1
        lastRemoveWishlistUserId = id
        lastRemovedWishlistProductId = productId
        return removeWishlistProductSubject.eraseToAnyPublisher()
    }

    // Is Product In Wishlist
    var isProductInWishlistCallCount = 0
    var lastIsProductInWishlistUserId: String?
    var lastIsProductInWishlistProductId: String?
    let isProductInWishlistSubject = PassthroughSubject<Bool, Error>()

    func isProductInWishlist(withProduct productId: String, forUser id: String)
        -> AnyPublisher<Bool, Error>
    {
        isProductInWishlistCallCount += 1
        lastIsProductInWishlistUserId = id
        lastIsProductInWishlistProductId = productId
        return isProductInWishlistSubject.eraseToAnyPublisher()
    }
}
