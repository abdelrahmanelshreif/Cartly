//
//  MockFirebaseServices.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 14/6/25.
//

import Foundation
import Combine
import FirebaseAuth
@testable import Cartly

enum MockError: Error {
    case generic
}

final class MockFirebaseServices: FirebaseServiceProtocol {

    // MARK: - Control Subjects
    let signInSubject = PassthroughSubject<String?, Error>()
    let signupSubject = PassthroughSubject<String?, Error>()
    let signOutSubject = PassthroughSubject<Void, Error>()
    let addProductToWishlistSubject = PassthroughSubject<Void, Error>()
    let removeProductFromWishlistSubject = PassthroughSubject<Void, Error>()
    let getUserWishlistSubject = PassthroughSubject<[WishlistProduct]?, Error>()
    let isProductInWishlistSubject = PassthroughSubject<Bool, Error>()
    let signInWithGoogleSubject = PassthroughSubject<User?, Error>()

    // MARK: - Spy Properties
    
    var signInCallCount = 0
    var lastSignInCredentials: (email: String, password: String)?
    
    var signupCallCount = 0
    var lastSignupCredentials: (email: String, password: String)?
    
    var signOutCallCount = 0
    
    var addProductToWishlistCallCount = 0
    var lastAddedWishlistProduct: WishlistProduct?
    var lastUserIdForAdd: String?
    
    var removeProductFromWishlistCallCount = 0
    var lastRemovedProductId: String?
    
    var getUserWishlistCallCount = 0
    var isProductInWishlistCallCount = 0
    var signInWithGoogleCallCount = 0

    // MARK: - Synchronous Method Control
    var currentUserToReturn: String?

    // MARK: - Protocol Conformance
    func signIn(email: String, password: String) -> AnyPublisher<String?, Error> {
        signInCallCount += 1
        lastSignInCredentials = (email, password)
        return signInSubject.eraseToAnyPublisher()
    }

    func signup(email: String, password: String) -> AnyPublisher<String?, Error> {
        signupCallCount += 1
        lastSignupCredentials = (email, password)
        return signupSubject.eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Void, Error> {
        signOutCallCount += 1
        return signOutSubject.eraseToAnyPublisher()
    }

    func getCurrentUser() -> String? {
        return currentUserToReturn
    }

    func addProductToWishlist(userId: String, product: WishlistProduct) -> AnyPublisher<Void, Error> {
        addProductToWishlistCallCount += 1
        lastUserIdForAdd = userId
        lastAddedWishlistProduct = product
        return addProductToWishlistSubject.eraseToAnyPublisher()
    }

    func removeProductFromWishlist(userId: String, productId: String) -> AnyPublisher<Void, Error> {
        removeProductFromWishlistCallCount += 1
        lastRemovedProductId = productId
        return removeProductFromWishlistSubject.eraseToAnyPublisher()
    }

    func getUserWishlist(userId: String) -> AnyPublisher<[WishlistProduct]?, Error> {
        getUserWishlistCallCount += 1
        return getUserWishlistSubject.eraseToAnyPublisher()
    }

    func isProductInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, Error> {
        isProductInWishlistCallCount += 1
        return isProductInWishlistSubject.eraseToAnyPublisher()
    }
    
    func signInWithGoogle() -> AnyPublisher<User?, Error> {
        signInWithGoogleCallCount += 1
        return signInWithGoogleSubject.eraseToAnyPublisher()
    }
}
