//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine

protocol AuthRepositoryProtocol {
    func signIn(credentials: EmailCredentials) -> AnyPublisher<String?, Error>
    func signup(signUpData: SignUpData) -> AnyPublisher<CustomerResponse?, Error>
    func signOut() -> AnyPublisher<Void, Error>
    
    func getCurrentLoggedInUserId() -> String?
    func getCurrentUserEmail() -> String?
    func getCurrentUserVerificationStatus() -> Bool?
    func isUserLoggedIn() -> Bool?
    
}
