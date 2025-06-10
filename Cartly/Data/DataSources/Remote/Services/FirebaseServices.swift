
//
//  FirebaseServiceProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

protocol FirebaseServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<String?, Error>
    func signup(email: String, password: String) -> AnyPublisher<String?, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> String?

    func addProductToWishlist(userId: String, product: WishlistProduct)-> AnyPublisher<Void, Error>
    func removeProductFromWishlist(userId: String, productId: String)-> AnyPublisher<Void, Error>
    func getUserWishlist(userId: String) -> AnyPublisher<[WishlistProduct]?, Error>
    func isProductInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, Error>
    
    func signInWithGoogle() -> AnyPublisher<User?, Error>
}

final class FirebaseServices: FirebaseServiceProtocol {
    
    private let googleSignInHelper = GoogleSignInHelper()
    private let firestore: Firestore = Firestore.firestore()
    private let userCollection = "users"
    private let wishlist = "wishlist"
    private let cart = "cart"

    func signIn(email: String, password: String) -> AnyPublisher<String?, Error>
    {
        return Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) {
                result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user.email))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signInWithGoogle() -> AnyPublisher<FirebaseAuth.User?, any Error> {
        return Future { [weak self] promise in
            Task {
                do {
                    guard
                        let authResult = try await self?.googleSignInHelper
                            .signIn()
                    else {
                        promise(.failure(AppError.firestoreNotAvailable))
                        return
                    }
                    promise(.success(authResult.user))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signup(email: String, password: String) -> AnyPublisher<String?, Error>
    {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) {
                result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user.email))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func getCurrentUser() -> String? {
        return Auth.auth().currentUser?.email
    }

    func addProductToWishlist(userId: String, product: WishlistProduct)
        -> AnyPublisher<Void, any Error>
    {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            let productData = try! Firestore.Encoder().encode(product)
            self.firestore
                .collection(self.userCollection)
                .document(userId)
                .collection(self.wishlist)
                .document(product.productId)
                .setData(productData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }

    func removeProductFromWishlist(userId: String, productId: String)
        -> AnyPublisher<Void, any Error>
    {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.userCollection)
                .document(userId)
                .collection(self.wishlist)
                .document(productId)
                .delete { error in
                    if let error = error {
                        promise(.failure(error))
                    }else{
                        promise(.success(()))
                    }

                }
        }.eraseToAnyPublisher()
    }

    func getUserWishlist(userId: String) -> AnyPublisher<[WishlistProduct]?, any Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.userCollection)
                .document(userId)
                .collection(self.wishlist)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Firestore error: \(error)")
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        promise(.success([]))
                        return
                    }

                    print("Found \(documents.count) documents")

                    let products: [WishlistProduct] = documents.compactMap {
                        document in
                        do {
                            let product = try document.data(
                                as: WishlistProduct.self)
                            print("Decoded product: \(product.title)")
                            return product
                        } catch {
                            print(
                                "Failed to decode document \(document.documentID): \(error)"
                            )
                            return nil
                        }
                    }

                    print("Returning \(products.count) products")
                    promise(.success(products))
                }
        }.eraseToAnyPublisher()
    }

    func isProductInWishlist(userId: String, productId: String) -> AnyPublisher<
        Bool, any Error
    > {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.userCollection)
                .document(userId)
                .collection(self.wishlist)
                .document(productId)
                .getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let exists = snapshot?.exists ?? false
                    promise(.success(exists))
                }
        }
        .eraseToAnyPublisher()
    }

}
