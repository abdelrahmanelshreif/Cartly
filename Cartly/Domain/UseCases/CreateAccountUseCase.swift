//
//  CreateAccountUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//

import Foundation
import Combine

protocol CreateAccountUseCaseProtocol {
    func execute(signUpData: SignUpData) -> AnyPublisher<CustomerResponse, Error>
}

class CreateAccountUseCase: CreateAccountUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let userSessionService: UserSessionServiceProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         userSessionService: UserSessionServiceProtocol) {
        self.authRepository = authRepository
        self.userSessionService = userSessionService
    }
    
    func execute(signUpData: SignUpData) -> AnyPublisher<CustomerResponse, Error> {
        print("[CreateAccountUseCase] Starting account creation for email: \(signUpData.email)")
        
        return authRepository.signup(signUpData: signUpData)
            .tryMap { [weak self] response in
                guard let self = self else {
                    print("[CreateAccountUseCase] Self deallocated during signup")
                    throw AuthError.signupFailed
                }
                
                guard let customerResponse = response else {
                    print("[CreateAccountUseCase] Signup returned nil response")
                    throw AuthError.signupFailed
                }
                
                guard let customer = customerResponse.customer else {
                    print("[CreateAccountUseCase] CustomerResponse has nil customer")
                    throw AuthError.signupFailed
                }
                
                print("[CreateAccountUseCase] Account created successfully for: \(customer.email)")
                print("[CreateAccountUseCase] Saving user session for customer ID: \(customer.id)")
                self.userSessionService.saveUserSession(customer)
                
                return customerResponse
            }
            .mapError { error -> Error in
                print("[CreateAccountUseCase] Account creation failed: \(error)")
                print("[CreateAccountUseCase] Error details: \(error)")
                
                if let authError = error as? AuthError {
                    return authError
                }
                
                if error.localizedDescription.contains("Firebase") ||
                   error.localizedDescription.contains("authentication") {
                    return AuthError.firebaseSignUpFailed
                }
                
                if error.localizedDescription.contains("Shopify") ||
                   error.localizedDescription.contains("customer") {
                    return AuthError.shopifySignUpFailed
                }
    
                return AuthError.signupFailed
            }
            .eraseToAnyPublisher()
    }
}
