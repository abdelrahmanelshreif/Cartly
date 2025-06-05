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
    
    func addProductToWishlist(userId: String, product: WishlistProduct) -> AnyPublisher<Void, Error>
    func removeProductFromWishlist(userId: String, productId: String) -> AnyPublisher<Void, Error>
    func getUserWishlist(userId: String) -> AnyPublisher <[WishlistProduct]?, Error>
    func isProductInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, Error>
}

final class FirebaseServices: FirebaseServiceProtocol {
    
    private let firestore: Firestore
    private let collection = "users"
    private let subcollection = "wishlist"
    
    
    init(firestore: Firestore = Firestore.firestore()) {
         self.firestore = firestore
     }
    
    
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
    
    func addProductToWishlist(userId: String, product: WishlistProduct) -> AnyPublisher<Void, any Error> {
        return Future { [weak self] promise in
            guard let self = self else{
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            let productData = mapProductToFirestoreData(product)
            self.firestore
                .collection(self.collection)
                .document(userId)
                .collection(self.subcollection)
                .document(product.id ?? "")
                .setData(productData){ error in
                    if let error = error {
                        promise(.failure(error))
                    }else{
                        promise(.success(()))
                    }
                }
                
        }.eraseToAnyPublisher()
    }
    
    func removeProductFromWishlist(userId: String, productId: String) -> AnyPublisher<Void, any Error> {
        return Future{ [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.collection)
                .document(userId)
                .collection(self.subcollection)
                .document(productId)
                .delete{ error in
                    if let error = error {
                        promise(.failure(AppError.firestoreNotAvailable))
                    }
                    
                }
        }.eraseToAnyPublisher()
    }
    
    func getUserWishlist(userId: String) -> AnyPublisher<[WishlistProduct]?, any Error> {
        return Future{ [weak self] promise in
            guard let self = self else{
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.collection)
                .document(userId)
                .collection(self.subcollection)
                .getDocuments{ snapshot , error in
                    guard let error = error else{
                        promise(.failure(AppError.failedFetchingDataFromNetwork))
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let products : [WishlistProduct] = documents.compactMap{ document in
                        try? document.data(as: WishlistProduct.self)
                    }
                    promise(.success(products))
                }
        }.eraseToAnyPublisher()
    }
        
    func isProductInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, any Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.firestoreNotAvailable))
                return
            }
            self.firestore
                .collection(self.collection)
                .document(userId)
                .collection(self.subcollection)
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
    
    
    private func mapProductToFirestoreData(_ product: WishlistProduct) -> [String: Any] {
           return [
               "title": product.title,
               "bodyHtml": product.bodyHtml,
               "vendor": product.vendor ?? "",
               "productType": product.productType,
               "status": product.status ?? "",
               "image": product.image ?? "",
               "addedAt": FieldValue.serverTimestamp()
           ]
       }
    
}
