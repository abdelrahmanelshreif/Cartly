//
//  LoginViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.
//

import Combine
import Foundation

class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var validationError: String?
    @Published var resultState: ResultState<String>? = nil
    private var cancellables = Set<AnyCancellable>()
    
    let loginUseCase: FirebaseShopifyLoginUseCaseProtocol
    let loginUsingGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol
    let validator: LoginValidatorProtocol
    
    init(loginUseCase: FirebaseShopifyLoginUseCase, validator: LoginValidator , loginUsingGoogleUseCase : AuthenticatingUserWithGoogleUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        self.validator = validator
        self.loginUsingGoogleUseCase = loginUsingGoogleUseCase
    }
   
    func login() {
        let emailsCredentials = EmailCredentials(email: email, password: password)
        
        switch validator.validate(emailsCredentials) {
        case .valid:
            validationError = nil
            performLogin(with: emailsCredentials)
        case .invalid(let error):
            validationError = error.localizedDescription
            return
        }
    }
    
    func loginWithGoogle() {
        validationError = nil
        performGoogleLogin()
    }
    
    private func performGoogleLogin() {
        loginUsingGoogleUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (state: ResultState<CustomerResponse?>) in
                switch state {
                case .success(let customerResponse):
                    self?.resultState = .success(customerResponse?.customer.firstName ?? "User")
                case .failure(let error):
                    self?.resultState = .failure(error)
                case .loading:
                    self?.resultState = .loading
                }
            }
            .store(in: &cancellables)
    }

    private func performLogin(with credentials: EmailCredentials) {
        loginUseCase.execute(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (state: ResultState<CustomerResponse?>) in
                switch state {
                case .success(let customerResponse):
                    self?.resultState = .success(customerResponse?.customer.firstName ?? "User")
                case .failure(let error):
                    self?.resultState = .failure(error)
                case .loading:
                    self?.resultState = .loading
                }
            }
            .store(in: &cancellables)
    }
}

