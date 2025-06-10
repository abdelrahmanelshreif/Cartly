//
//  SignOutUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//

import Combine

protocol SignOutUseCaseProtocol {
    func execute() -> Bool
}

struct SignOutUseCase: SignOutUseCaseProtocol {
    
    private let userSessionManager = UserSessionService()
    
    func execute() -> Bool{
        userSessionManager.clearUserSession()
        return true
    }
}
