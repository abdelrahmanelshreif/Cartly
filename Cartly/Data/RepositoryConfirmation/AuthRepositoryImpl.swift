//
//  AuthRepositoryImpl.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import FirebaseAuth
import Foundation

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

    func signInWithGoogle() -> AnyPublisher<User?, any Error> {
        return firebaseAuthClient.signInWithGoogle()
    }

    func signup(signUpData: SignUpData) -> AnyPublisher<
        CustomerResponse?, Error> {
        return shopifyAuthClient.signup(userData: signUpData)
            .flatMap {
                [weak self] customer -> AnyPublisher<CustomerResponse?, Error>
                in
                guard let self = self, let customer = customer else {
                    return Fail(error: AuthError.shopifySignUpFailed)
                        .eraseToAnyPublisher()
                }

                let firebaseSignupPublisher = self.firebaseAuthClient.signup(
                    email: signUpData.email,
                    password: signUpData.password!
                )
                return
                    firebaseSignupPublisher

                    .map { firebaseUser -> CustomerResponse? in
                        print("Successfully signed up user in Firebase with : \(String(describing: firebaseUser?.email))")
                        firebaseUser?.sendEmailVerification { error in
                            if let error = error {
                                print(
                                    "Failed to send verification email: \(error.localizedDescription)"
                                )
                            } else {
                                print("Verification email sent successfully.")
                            }
                        }
                        return customer
                    }
                    .catch { error -> AnyPublisher<CustomerResponse?, Error> in
                        print(
                            "Firebase signup failed. Error: \(error.localizedDescription)"
                        )
                        return Fail(error: AuthError.firebaseSignUpFailed)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func createShopifyUser(signupData: SignUpData) -> AnyPublisher<
        CustomerResponse?, Error> {
        return shopifyAuthClient.signup(userData: signupData)
    }

    func signIn(credentials: EmailCredentials) -> AnyPublisher<User?, Error> {
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

    func getCurrentUsrname() -> String? {
        return userSessionServices.getCurrentUserName()
    }

}
