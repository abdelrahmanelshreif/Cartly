//
//  LoginViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.
//

import Combine
import Foundation

class LoginViewModel: ObservableObject{
    
    @Published var email = ""
    @Published var password = ""
    @Published var validationError:String?
    @Published var resultState:ResultState<String>? = nil
    private var cancellables = Set<AnyCancellable>()
    
    
    let loginUseCase:LoginUseCase
    let validator:LoginValidator
    
    init(loginUseCase: LoginUseCase, validator: LoginValidator) {
        self.loginUseCase = loginUseCase
        self.validator = validator
    }
   
    func login(){
        let emailsCredentials = EmailCredentials(email: email, password: password)
    
        switch validator.validate(emailsCredentials) {
        case .valid:
            validationError = nil
        case .invalid(let error):
            validationError = error.localizedDescription
        }
                
        
        loginUseCase.execute(emailCredentials: emailsCredentials)
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] state in
                switch state {
                case .success(let token):
                    print(token as Any)
                    self?.resultState = .success(token ?? "Account not Available")
                case .failure(let error):
                    self?.resultState = .failure(error)
                case .loading:
                    self?.resultState = .loading
                }
            }.store(in: &cancellables)
    }

    private func clearForm() {
        email = ""
        password = ""
    }
    
    
}
