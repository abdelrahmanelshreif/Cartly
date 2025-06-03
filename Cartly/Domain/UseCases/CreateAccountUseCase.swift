//
//  CreateAccountUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Foundation
import Combine

protocol CreateAccountUseCaseProtocol {
    func execute(signUpData: SignUpData) -> AnyPublisher<ResultState<CustomerResponse?>, Never>
}

class CreateAccountUseCase: CreateAccountUseCaseProtocol{
    
    private let authRepository: AuthRepositoryProtocol
    private let userSessionService: UserSessionServiceProtocol
    
    init(authRepository: AuthRepositoryProtocol,
           userSessionService: UserSessionServiceProtocol) {
          self.authRepository = authRepository
          self.userSessionService = userSessionService
      }
    
    
    func execute(signUpData: SignUpData) -> AnyPublisher<ResultState<CustomerResponse?>, Never> {
        return authRepository.signup(signUpData: signUpData)
               .map { [weak self] response in
                   if let customer = response?.customer {
                    self?.userSessionService.saveUserSession(customer)
                }
                return ResultState.success(response)
            }
            .catch { error in
                Just(ResultState.failure(error))
            }
            .prepend(ResultState.loading)
            .eraseToAnyPublisher()
    }
}
