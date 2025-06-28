//
//  LoginFirebaseShopifyUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//

import Foundation
import Combine
import FirebaseAuth

protocol FirebaseShopifyLoginUseCaseProtocol {
    func execute(credentials: EmailCredentials) -> AnyPublisher<CustomerResponse, Error>
}

class FirebaseShopifyLoginUseCase: FirebaseShopifyLoginUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let customerRepository: RepositoryProtocol
    private let userSessionService: UserSessionServiceProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        customerRepository: RepositoryProtocol,
        userSessionService: UserSessionServiceProtocol
    ) {
        self.authRepository = authRepository
        self.customerRepository = customerRepository
        self.userSessionService = userSessionService
    }
    
    func execute(credentials: EmailCredentials) -> AnyPublisher<CustomerResponse, Error> {
        print("[LoginUseCase] Starting login process for email: \(credentials.email)")
        
        return authRepository.signIn(credentials: credentials)
            .flatMap { [weak self] firebaseUser -> AnyPublisher<CustomerResponse, Error> in
                guard let self = self else {
                    print("[LoginUseCase] Self deallocated during Firebase sign-in")
                    return Fail(error: AuthError.firebaseloginFailed)
                        .eraseToAnyPublisher()
                }
                
                guard let user = firebaseUser else {
                    print("[LoginUseCase] Firebase sign-in returned nil email")
                    return Fail(error: AuthError.firebaseloginFailed)
                        .eraseToAnyPublisher()
                }
                userSessionService.setVerificationStatus(user.isEmailVerified)
                print("[LoginUseCase] Firebase authentication successful for: \(user.email ?? "Unkown")")
                print("[LoginUseCase] Firebase EMAIL VERIFICATION \(user.isEmailVerified)")
                return self.fetchAndMatchCustomer(for: credentials.email)
            }
            .mapError { error -> Error in
                print("[LoginUseCase] Firebase authentication error: \(error)")
                if let authError = error as? AuthError {
                    return authError
                }
                return AuthError.firebaseloginFailed
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchAndMatchCustomer(for email: String) -> AnyPublisher<CustomerResponse, Error> {
        print("[LoginUseCase] Fetching customer data from Shopify...")
        
        return customerRepository.getCustomers()
            .tryMap { [weak self] customersResponse -> CustomerResponse in
                guard let self = self else {
                    throw AuthError.shopifyLoginFailed
                }
                
                guard let customers = customersResponse?.customers else {
                    print("[LoginUseCase] Shopify returned nil or empty customers response")
                    throw AuthError.shopifyLoginFailed
                }
                
                print("[LoginUseCase] Received \(customers.count) customers from Shopify")
                
                let matchingCustomer = customers.first { customer in
                    let matches = customer.email.lowercased() == email.lowercased()
                    if matches {
                        print("[LoginUseCase] Found matching customer: ID=\(customer.id ), Email=\(customer.email)")
                    }
                    return matches
                }
                
                guard let customer = matchingCustomer else {
                    print(" [LoginUseCase] No customer found in Shopify with email: \(email)")
                    print("[LoginUseCase] Available emails in Shopify: \(customers.map { $0.email }.joined(separator: ", "))")
                    throw AuthError.customerNotFoundAtShopify
                }
                
                print("[LoginUseCase] Saving user session for customer ID: \(customer.id)")
                self.userSessionService.saveUserSession(customer)
                
                return CustomerResponse(customer: customer)
            }
            .mapError { error -> Error in
                print("[LoginUseCase] Shopify operation failed: \(error)")
                print("[LoginUseCase] Error details: \(error)")
                
                if let authError = error as? AuthError {
                    return authError
                }
                return AuthError.shopifyLoginFailed
            }
            .eraseToAnyPublisher()
    }
}
