//
//  AuthenticatingUserWithGoogleUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 10/6/25.
//

import Combine

protocol AuthenticatingUserWithGoogleUseCaseProtocol {
    func execute() -> AnyPublisher<CustomerResponse, Error>
}

class AuthenticatingUserWithGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol {

    let authRepository: AuthRepositoryProtocol
    let shopifyRepo: RepositoryProtocol
    let userSessionService: UserSessionServiceProtocol

    init(
        authRepository: AuthRepositoryProtocol,
        shopifyRepo: RepositoryProtocol,
        userSessionService: UserSessionServiceProtocol
    ) {
        self.authRepository = authRepository
        self.shopifyRepo = shopifyRepo
        self.userSessionService = userSessionService
    }

    func execute() -> AnyPublisher<CustomerResponse, Error> {
        print("[GoogleLoginUseCase] Starting Google authentication process")
        
        return authRepository.signInWithGoogle()
            .flatMap { [weak self] googleUser -> AnyPublisher<CustomerResponse, Error> in
                guard let self = self else {
                    print("[GoogleLoginUseCase] Self deallocated during Google sign-in")
                    return Fail(error: AuthError.firebaseloginFailed)
                        .eraseToAnyPublisher()
                }
                
                guard let userEmail = googleUser?.email else {
                    print("[GoogleLoginUseCase] Google sign-in returned nil email")
                    return Fail(error: AuthError.firebaseloginFailed)
                        .eraseToAnyPublisher()
                }
                
                print("[GoogleLoginUseCase] Google authentication successful for: \(userEmail)")
                let displayName = googleUser?.displayName ?? "Google User"
                
                return self.findOrCreateShopifyCustomer(
                    email: userEmail,
                    displayName: displayName
                )
            }
            .mapError { error -> Error in
                print("[GoogleLoginUseCase] Google authentication error: \(error)")
                if let authError = error as? AuthError {
                    return authError
                }
                return AuthError.firebaseloginFailed
            }
            .eraseToAnyPublisher()
    }
    
    private func findOrCreateShopifyCustomer(
        email: String,
        displayName: String
    ) -> AnyPublisher<CustomerResponse, Error> {
        print("[GoogleLoginUseCase] Checking if customer exists in Shopify...")
        
        return shopifyRepo.getCustomers()
            .flatMap { [weak self] customersResponse -> AnyPublisher<CustomerResponse, Error> in
                guard let self = self else {
                    return Fail(error: AuthError.shopifyLoginFailed)
                        .eraseToAnyPublisher()
                }
                
                guard let customers = customersResponse?.customers else {
                    print("[GoogleLoginUseCase] Shopify returned nil customers")
                    return Fail(error: AuthError.shopifyLoginFailed)
                        .eraseToAnyPublisher()
                }
                
                print("[GoogleLoginUseCase] Received \(customers.count) customers from Shopify")
                
                if let existingCustomer = customers.first(where: {
                    $0.email.lowercased() == email.lowercased()
                }) {
                    print("[GoogleLoginUseCase] Found existing customer: ID=\(existingCustomer.id )")
                    print("[GoogleLoginUseCase] Saving user session")
                    self.userSessionService.saveUserSession(existingCustomer)
                    return Just(CustomerResponse(customer: existingCustomer))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    print("[GoogleLoginUseCase] Customer not found, creating new Shopify account")
                    return self.createNewShopifyCustomer(
                        email: email,
                        displayName: displayName
                    )
                }
            }
            .mapError { error -> Error in
                print("[GoogleLoginUseCase] Shopify operation failed: \(error)")
                if let authError = error as? AuthError {
                    return authError
                }
                return AuthError.shopifyLoginFailed
            }
            .eraseToAnyPublisher()
    }
    
    private func createNewShopifyCustomer(
        email: String,
        displayName: String
    ) -> AnyPublisher<CustomerResponse, Error> {
        let newCustomerData = SignUpData(
            firstname: displayName,
            lastname: "",
            email: email,
            password: nil,
            passwordConfirm: nil,
            sendinEmailVerification: false
        )
        
        print("[GoogleLoginUseCase] Creating new Shopify customer with email: \(email)")
        
        return authRepository.createShopifyUser(signupData: newCustomerData)
            .tryMap { [weak self] createdCustomerResponse in
                guard let self = self else {
                    throw AuthError.shopifySignUpFailed
                }
                
                guard let customerResponse = createdCustomerResponse else {
                    print("[GoogleLoginUseCase] Shopify returned nil customer response")
                    throw AuthError.shopifySignUpFailed
                }
                
                print("[GoogleLoginUseCase] Successfully created new Shopify customer: ID=\(customerResponse.customer.id)")
                print("[GoogleLoginUseCase] Saving user session")
                self.userSessionService.saveUserSession(customerResponse.customer)
                
                return customerResponse
            }
            .mapError { error -> Error in
                print("[GoogleLoginUseCase] Failed to create Shopify customer: \(error)")
                if let authError = error as? AuthError {
                    return authError
                }
                return AuthError.shopifySignUpFailed
            }
            .eraseToAnyPublisher()
    }
}
