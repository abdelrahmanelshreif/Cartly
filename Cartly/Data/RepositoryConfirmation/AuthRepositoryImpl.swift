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
                      password: signUpData.password ?? ""
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
    
    func shopifySignup(signUpData:SignUpData) -> AnyPublisher<CustomerResponse?, Error>{
        return shopifyAuthClient.signup(userData: signUpData)
    }
  
    func signIn(email:String,password:String) -> AnyPublisher<User?, Error> {
        return firebaseAuthClient.signIn(
            email: email,
            password: password
        ).eraseToAnyPublisher()
    }
    
    func signInWithGoogle() -> AnyPublisher<User?, Error> {
          return firebaseAuthClient.signInWithGoogle()
              .eraseToAnyPublisher()
      }
    
    func signupWithGoogle() -> AnyPublisher<CustomerResponse?, Error> {
        return signInWithGoogle()
            .flatMap { [weak self] user -> AnyPublisher<CustomerResponse?, Error> in
                guard let self = self, let user = user else {
                    return Fail(error: AuthError.googleSignInFalied)
                        .eraseToAnyPublisher()
                }
                let newCustomerData = SignUpData(firstname: user.displayName ?? "Google User", lastname: nil, email: user.email!, password: nil, phone: nil, passwordConfirm: nil, sendinEmailVerification: nil)
             
                return self.shopifySignup(signUpData: newCustomerData)
            }
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
