//
//  SignUpViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var resultState:ResultState<CustomerResponse>? = nil
    @Published var validationError: String?

    private let createAccountUseCase: CreateAccountUseCaseProtocol
    private let validator: SignUpValidatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        createAccountUseCase: CreateAccountUseCaseProtocol,
        validator: SignUpValidatorProtocol
    ) {
        self.createAccountUseCase = createAccountUseCase
        self.validator = validator
    }
    
    func createAccount() {
           let signUpData = SignUpData(
               firstname: firstName,
               lastname: lastName,
               email: email,
               password: password,
               phone: phone,
               passwordConfirm: password,
               sendinEmailVerification: BuissnessStrategies.sendEmails
           )

           switch validator.validate(signUpData) {
           case .invalid(let error):
               validationError = error.errorDescription
               return
           case .valid:
               validationError = nil
           }

           resultState = .loading

        createAccountUseCase.execute(signUpData: signUpData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .success(let customerResponse):
                    guard let response = customerResponse else {return}
                    self?.resultState = .success(response)
                    print(response.customer.phone)
                case .failure(let error):
                    self?.resultState = .failure(error)

                case .loading:
                    self?.resultState = .loading
                }
            }.store(in: &cancellables)

        
       }

       private func clearForm() {
           firstName = ""
           lastName = ""
           email = ""
           phone = ""
           password = ""
       }
    
   }

