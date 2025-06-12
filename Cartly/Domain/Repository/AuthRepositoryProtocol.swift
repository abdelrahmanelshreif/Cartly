//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import FirebaseAuth

protocol AuthRepositoryProtocol {
    func signIn(credentials: EmailCredentials) -> AnyPublisher<String?, Error>
    func signInWithGoogle() -> AnyPublisher<User?, Error>
    func signup(signUpData: SignUpData) -> AnyPublisher<CustomerResponse?, Error>
    func createShopifyUser(signupData: SignUpData) -> AnyPublisher<CustomerResponse?, Error>
    func signOut() -> AnyPublisher<Void, Error>
    
    func getCurrentLoggedInUserId() -> String?
    func getCurrentUserEmail() -> String?
    func getCurrentUserVerificationStatus() -> Bool?
    func isUserLoggedIn() -> Bool?
    func getCurrentUsrname() -> String?
    
}
