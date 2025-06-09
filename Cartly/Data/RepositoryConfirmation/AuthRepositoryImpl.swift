//
//  AuthRepositoryImpl.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Foundation
import Combine	
import FirebaseAuth

class AuthRepositoryImpl: AuthRepositoryProtocol {

    let firebaseAuthClient: FirebaseServiceProtocol
    let shopifyAuthClient: ShopifyServicesProtocol
    let userSessionServices: UserSessionServiceProtocol
    static let shared = AuthRepositoryImpl()
    
    private init() {
        firebaseAuthClient = FirebaseServices()
        shopifyAuthClient = ShopifyServices()
        userSessionServices = UserSessionService()
    }
    
    func signup(signUpData: SignUpData) -> AnyPublisher<CustomerResponse?, Error> {
          return shopifyAuthClient.signup(userData: signUpData)
              .flatMap { [weak self] customer -> AnyPublisher<CustomerResponse?, Error> in
                  guard let self = self, let customer = customer else {
                      return Fail(error: AuthError.shopifySignUpFailed)
                          .eraseToAnyPublisher()
                  }
                  
                  return self.firebaseAuthClient.signup(
                      email: signUpData.email,
                      password: signUpData.password
                  )
                  .map { _ in customer }
                  .catch { error -> AnyPublisher<CustomerResponse?, Error> in
                      return Fail(error: AuthError.firebaseSignUpFailed)
                          .eraseToAnyPublisher()
                  }
                  .eraseToAnyPublisher()
              }
              .eraseToAnyPublisher()
    }
  
    func signIn(email:String,password:String) -> AnyPublisher<String?, Error> {
        return firebaseAuthClient.signIn(
            email: email,
            password: password
        )
        .compactMap { $0 }	
        .mapError { _ in AuthError.signinFalied }
        .eraseToAnyPublisher()
    }
    
    func signInWithGoogle() -> AnyPublisher<String?, Error> {
          return firebaseAuthClient.signInWithGoogle()
              .eraseToAnyPublisher()
      }
    func signOut() -> AnyPublisher<Void, Error> {
        return firebaseAuthClient.signOut()
            .eraseToAnyPublisher()
    }
    
    func getCurrentLoggedInUserId() -> String? {
        return userSessionServices.getCurrentUserId()
    }
    
    func getCurrentUserEmail() -> String? {
        return userSessionServices.getCurrentUserEmail()
    }
    
    func getCurrentUserVerificationStatus() -> Bool? {
        return userSessionServices.isUserEmailVerified()
    }
    
    func isUserLoggedIn() -> Bool? {
        return userSessionServices.isUserLoggedIn()
    }
    
}
