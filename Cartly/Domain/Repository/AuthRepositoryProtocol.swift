//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import FirebaseAuth

protocol AuthRepositoryProtocol {
    func signup(signUpData: SignUpData) -> AnyPublisher<CustomerResponse?, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func getCurrentLoggedInUserId() -> String?
    func getCurrentUserEmail() -> String?
    func getCurrentUserVerificationStatus() -> Bool?
    func isUserLoggedIn() -> Bool?
    func signIn(email:String,password:String) -> AnyPublisher<User?, Error>
    func signInWithGoogle() -> AnyPublisher<User?, Error>
}
