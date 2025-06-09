//
//  LoginUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Foundation
import Combine

protocol LoginUseCaseProtocol{
    func execute(emailCredentials:EmailCredentials) -> AnyPublisher<ResultState<String?>,Never>
}

class LoginUseCase : LoginUseCaseProtocol{
    
    private let authRepository: AuthRepositoryProtocol
    private let userSessionService: UserSessionServiceProtocol
    
    init(authRepository: AuthRepositoryProtocol,
           userSessionService: UserSessionServiceProtocol) {
          self.authRepository = authRepository
          self.userSessionService = userSessionService
      }
    
    func execute(emailCredentials:EmailCredentials) -> AnyPublisher<ResultState<String?>, Never> {
        return authRepository.signIn(email: emailCredentials.password, password: emailCredentials.password)
            .map{ResultState.success($0)}
            .catch{error in
                Just(ResultState.failure(error.localizedDescription))
            }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
