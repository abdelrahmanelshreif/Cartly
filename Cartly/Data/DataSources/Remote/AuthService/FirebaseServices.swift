//
//  FirebaseServiceProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import FirebaseAuth

protocol FirebaseServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<String?, Error>
    func signup(email: String, password: String) -> AnyPublisher<String?, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> String?
}

final class FirebaseServices: FirebaseServiceProtocol {
    
    func signIn(email: String, password: String) -> AnyPublisher<String?, Error> {
        return Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
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
    
    func signup(email: String, password: String) -> AnyPublisher<String?, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
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
}
