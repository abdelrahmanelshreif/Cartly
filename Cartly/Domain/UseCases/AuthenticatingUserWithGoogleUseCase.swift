//
//  AuthenticatingUserWithGoogleUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 10/6/25.
//

import Combine

protocol AuthenticatingUserWithGoogleUseCaseProtocol {
    func execute() -> AnyPublisher<ResultState<CustomerResponse?>, Never>
}

struct AuthenticatingUserWithGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol {

    let authRepository: AuthRepositoryProtocol
    let shopifyRepo: RepositoryProtocol
    let userSessionService: UserSessionServiceProtocol

    init(
        authRepository: AuthRepositoryProtocol, shopifyRepo: RepositoryProtocol,
        userSessionService: UserSessionServiceProtocol
    ) {
        self.authRepository = authRepository
        self.shopifyRepo = shopifyRepo
        self.userSessionService = userSessionService
    }

    func execute() -> AnyPublisher<ResultState<CustomerResponse?>, Never> {
        return authRepository.signInWithGoogle()
            .flatMap {
                googleUser -> AnyPublisher<
                    ResultState<CustomerResponse?>, Never
                > in
                guard let userEmail = googleUser?.email else {
                    return Just(ResultState.failure("Google Login Failed"))
                        .eraseToAnyPublisher()
                }

                return self.shopifyRepo.getCustomers()
                    .flatMap {
                        customersResponse -> AnyPublisher<
                            ResultState<CustomerResponse?>, Never
                        > in
                        guard let customers = customersResponse?.customers
                        else {
                            return Just(
                                ResultState.failure("Shopify Login Failed")
                            )
                            .eraseToAnyPublisher()
                        }

                        if let customer = customers.first(where: {
                            $0.email.lowercased() == userEmail.lowercased()
                        }) {
                            self.userSessionService.saveUserSession(customer)
                            return Just(
                                ResultState.success(
                                    CustomerResponse(customer: customer))
                            )
                            .eraseToAnyPublisher()
                        } else {
                            let newCustomerData = SignUpData(
                                firstname: googleUser?.displayName
                                    ?? "Google User",
                                lastname: "",
                                email: userEmail,
                                password: nil,
                                phone: nil,
                                passwordConfirm: nil,
                                sendinEmailVerification: true
                            )

                            return self.authRepository.createShopifyUser(
                                signupData: newCustomerData
                            )
                            .map { createdCustomerResponse in
                                if let customerReponse = createdCustomerResponse {
                                    self.userSessionService.saveUserSession(customerReponse.customer)
                                    return ResultState.success(customerReponse)
                                } else {
                                    return ResultState.failure(
                                        "Failed to create Shopify user")
                                }
                            }
                            .catch { _ in
                                Just(
                                    ResultState.failure(
                                        "Shopify Creation User Failed"))
                            }
                            .eraseToAnyPublisher()
                        }
                    }
                    .catch { _ in
                        Just(ResultState.failure("Shopify Login Failed"))
                    }
                    .eraseToAnyPublisher()
            }
            .catch { _ in
                Just(ResultState.failure("Google Login Failed"))
            }
            .prepend(ResultState.loading)
            .eraseToAnyPublisher()
    }

}
