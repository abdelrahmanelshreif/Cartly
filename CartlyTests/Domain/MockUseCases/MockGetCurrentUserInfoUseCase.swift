//
//  MockGetCurrentUserInfoUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import XCTest
import Combine
@testable import Cartly



class MockGetCurrentUserInfoUseCase: GetCurrentUserInfoUseCaseProtocol {
    var userToReturn: UserEntity = UserEntity(id: "", email: "body@gmail.com", emailVerificationStatus: true, sessionStatus: true, name: "Abdelrahman")
    
    func execute() -> UserEntity {
        return userToReturn
    }
}
