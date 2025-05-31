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
    
    private let authRepository : AuthRepositoryImpl
    
    init(authRepository: AuthRepositoryImpl) {
        self.authRepository = authRepository
    }
    
    func execute(emailCredentials:EmailCredentials) -> AnyPublisher<ResultState<String?>, Never> {
        return authRepository.signIn(credentials: emailCredentials)
            .map{ResultState.success($0)}
            .catch{error in
                Just(ResultState.failure(error))
            }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
    
    
}
