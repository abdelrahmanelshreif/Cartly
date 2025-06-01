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

class CreateAccountUseCase: CreateAccountUseCaseProtocol {
    
    private let authRepository:AuthRepositoryImpl
    
    init(authRepository: AuthRepositoryImpl) {
        self.authRepository = authRepository
    }
    
    func execute(signUpData: SignUpData) -> AnyPublisher<ResultState<CustomerResponse?>, Never> {
        return authRepository.signup(signUpData: signUpData)
            .map { ResultState.success($0) }
            .catch { error in
                Just(ResultState.failure(error))
            }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
