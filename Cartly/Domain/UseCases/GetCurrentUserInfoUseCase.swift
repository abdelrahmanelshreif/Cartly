//
//  GetCurrentUser.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

protocol GetCurrentUserInfoUseCaseProtocol{
    func execute() -> UserEntity
}

struct  GetCurrentUserInfoUseCase : GetCurrentUserInfoUseCaseProtocol{
    
    private let authenticationRepo : AuthRepositoryProtocol
    
    init(authenticationRepo: AuthRepositoryProtocol) {
        self.authenticationRepo = authenticationRepo
    }
    
    func execute() -> UserEntity {
        return UserEntity(id: authenticationRepo.getCurrentLoggedInUserId() ?? "N/A", email: authenticationRepo.getCurrentUserEmail() ?? "N/A", emailVerificationStatus: authenticationRepo.getCurrentUserVerificationStatus() ?? false, sessionStatus: authenticationRepo.isUserLoggedIn() ?? false, name: authenticationRepo.getCurrentUsrname() ?? "Cartly User")
    }

}
