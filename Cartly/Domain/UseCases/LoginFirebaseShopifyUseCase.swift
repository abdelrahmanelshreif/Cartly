//
//  LoginFirebaseShopifyUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//

import Foundation
import Combine

protocol FirebaseShopifyLoginUseCaseProtocol {
    func execute(credentials: EmailCredentials) -> AnyPublisher<ResultState<CustomerResponse?>, Never>
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
    
    func execute(credentials: EmailCredentials) -> AnyPublisher<ResultState<CustomerResponse?>, Never> {
        
        return authRepository.signIn(credentials: credentials)
            .flatMap { [weak self] userEmail -> AnyPublisher<ResultState<CustomerResponse?>, Never> in
                guard let self = self, let _ = userEmail else {
                    return Just(ResultState.failure("firebaseloginFailed"))
                        .eraseToAnyPublisher()
                }
                
                return self.customerRepository.getCustomers()
                    .map { customersResponse in
                        guard let customers = customersResponse?.customers else {
                            return ResultState.failure("shopifyLoginFailed")
                        }
                        
                        let matchingCustomer = customers.first { customer in
                            customer.email.lowercased() == credentials.email.lowercased()
                        }
                        
                        if let customer = matchingCustomer {
                            self.userSessionService.saveUserSession(customer)
                            let customerResponse = CustomerResponse(customer: customer)
                            return ResultState.success(customerResponse)
                        } else {
                            return ResultState.failure("customerNotFoundAtShopify")
                        }
                    }
                    .catch { error in
                        Just(ResultState.failure("shopifyLoginFailed"))
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error in
                Just(ResultState.failure("firebaseloginFailed"))
            }
            .prepend(ResultState.loading)
            .eraseToAnyPublisher()
        }
}
