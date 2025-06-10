//
//  ProfileViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 9/6/25.
//
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    private let signOutUseCase: SignOutUseCaseProtocol
    private let getUserSession: GetCurrentUserInfoUseCaseProtocol

    @Published var loading = false
    @Published var didSignOut = false
    @Published var currentUser: UserEntity?

    init(
        signOutUseCase: SignOutUseCaseProtocol,
        getUserSession: GetCurrentUserInfoUseCaseProtocol
    ) {
        self.signOutUseCase = signOutUseCase
        self.getUserSession = getUserSession

        checkUserSession()
    }

    func checkUserSession() {
        currentUser = getUserSession.execute()

        guard let user = currentUser else {
            print("No user session found.")
            didSignOut = true
            return
        }

        if user.sessionStatus == false {
            print("User session is inactive.")
            didSignOut = true
        }
    }

    func signOut() {
        loading = true

        DispatchQueue.global().async {
            let success = self.signOutUseCase.execute()

            DispatchQueue.main.async {
                self.loading = false
                if success {
                    self.didSignOut = true
                }
            }
        }
    }

}
