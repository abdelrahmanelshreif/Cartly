//
//  GoogleSignInUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 10/6/25.
//

import Combine

protocol GoogleSignInUseCaseProtocol{
    func execute() -> AnyPublisher<ResultState<CustomerResponse?>,Never>
}

struct GoogleSignInUseCase:GoogleSignInUseCaseProtocol{

    let authRepository:AuthRepositoryProtocol
    let shopifyRepo:RepositoryProtocol
    let userSessionService:UserSessionServiceProtocol
    
    init(authRepository: AuthRepositoryProtocol, shopifyRepo: RepositoryProtocol, userSessionService: UserSessionServiceProtocol) {
        self.authRepository = authRepository
        self.shopifyRepo = shopifyRepo
        self.userSessionService = userSessionService
    }
    
    func execute() -> AnyPublisher<ResultState<CustomerResponse?>, Never> {
        return authRepository.signInWithGoogle()
            .flatMap {  googleUser -> AnyPublisher<ResultState<CustomerResponse?>, Never> in
                guard let userEmail = googleUser?.email else {
                    return Just(ResultState.failure("Google Login Failed"))
                        .eraseToAnyPublisher()
                }
                return self.shopifyRepo.getCustomers()
                    .map { customersResponse in
                        guard let customers = customersResponse?.customers else {
                            return ResultState.failure("Shopify Login Failed")
                        }
                        
                        let matchingCustomer = customers.first { customer in
                            customer.email.lowercased() == userEmail.lowercased()
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
                Just(ResultState.failure("googleLoginFailed"))
            }
            .prepend(ResultState.loading)
            .eraseToAnyPublisher()
    }
}

