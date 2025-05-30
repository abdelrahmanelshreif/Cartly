//
//  AuthRepositoryImpl.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Foundation
import Combine

class AuthRepositoryImpl: AuthRepositoryProtocol {
    typealias CredentialsType = EmailCredentials
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    typealias Token = String
    
    let firebaseAuthClient: FirebaseServiceProtocol
    let shopifyAuthClient: ShopifyServices
    
    static let shared = AuthRepositoryImpl()
    
    private init() {
        firebaseAuthClient = FirebaseServices()
        shopifyAuthClient = ShopifyServices()
    }
    
    func signup(signUpData: SignUpData) -> AnyPublisher<Customer, Error> {

        return shopifyAuthClient.signup(userData: signUpData)
            .flatMap { [weak self] customer -> AnyPublisher<Customer, Error> in
                guard let self = self, let customer = customer else {
                    return Fail(error: AuthError.shopifySignUpFailed)
                        .eraseToAnyPublisher()
                }
                
                return self.firebaseAuthClient.signup(
                    email: signUpData.email,
                    password: signUpData.password
                )
                .map { _ in customer }
                .catch { error -> AnyPublisher<Customer, Error> in
                    return Fail(error: AuthError.firebaseSignUpFailed)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func signIn(credentials: EmailCredentials) -> AnyPublisher<String, Error> {
        return firebaseAuthClient.signIn(
            email: credentials.email,
            password: credentials.password
        )
        .compactMap { $0 }
        .mapError { _ in AuthError.signinFalied }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        return firebaseAuthClient.signOut()
            .eraseToAnyPublisher()
    }
}
