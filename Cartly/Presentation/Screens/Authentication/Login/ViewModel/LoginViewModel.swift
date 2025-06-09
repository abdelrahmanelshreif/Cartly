//
//  LoginViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.

import Combine
import Foundation
import GoogleSignIn

class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var validationError: String?
    @Published var resultState: ResultState<String>? = nil
    @Published var shouldNavigateToHome = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let loginUseCase: FirebaseShopifyLoginUseCaseProtocol
    let validator: LoginValidatorProtocol
    
    init(loginUseCase: FirebaseShopifyLoginUseCaseProtocol, validator: LoginValidator) {
        self.loginUseCase = loginUseCase
        self.validator = validator
    }
   
    func login() {
        let emailCredentials = EmailCredentials(email: email, password: password)
        
        switch validator.validate(emailCredentials) {
        case .valid:
            validationError = nil
            performLogin(with: .email(credentials: emailCredentials))
        case .invalid(let error):
            validationError = error.localizedDescription
            return
        }
    }
    
    func loginWithGoogle(presenting viewController: UIViewController) {
        validationError = nil
        performLogin(with: .google(presenting: viewController))
    }
    
    private func performLogin(with credentials: LoginCredentials) {
        loginUseCase.execute(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (state: ResultState<CustomerResponse?>) in
                switch state {
                case .success(let customerResponse):
                    if let customer = customerResponse?.customer {
                        self?.resultState = .success(customer.firstName)
                        self?.shouldNavigateToHome = true
                    } else {
                        self?.resultState = .failure("")
                    }
                case .failure(let error):
                    self?.resultState = .failure(error)
                    self?.validationError = error
                case .loading:
                    self?.resultState = .loading
                }
            }
            .store(in: &cancellables)
    }
}
