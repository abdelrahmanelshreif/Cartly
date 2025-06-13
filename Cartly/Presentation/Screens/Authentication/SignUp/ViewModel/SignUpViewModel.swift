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
    @Published var resultState: ResulteAuthenticationState<CustomerResponse> = .none
    @Published var validationError: String?

    private let createAccountUseCase: CreateAccountUseCaseProtocol
    private let googleSignInUseCase: AuthenticatingUserWithGoogleUseCaseProtocol
    private let validator: SignUpValidatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        createAccountUseCase: CreateAccountUseCaseProtocol,
        googleSignInUseCase: AuthenticatingUserWithGoogleUseCaseProtocol,
        validator: SignUpValidatorProtocol
    ) {
        self.createAccountUseCase = createAccountUseCase
        self.googleSignInUseCase = googleSignInUseCase
        self.validator = validator
    }
    
    func createAccount() {
        let signUpData = SignUpData(
            firstname: firstName,
            lastname: lastName,
            email: email,
            password: password,
            passwordConfirm: password,
            sendinEmailVerification: BuissnessStrategies.sendEmails
        )

        switch validator.validate(signUpData) {
        case .invalid(let error):
            validationError = error.errorDescription
            print("[SignUpViewModel] Validation failed: \(error.errorDescription ?? "Unknown error")")
            return
        case .valid:
            validationError = nil
            print("[SignUpViewModel] Validation passed, proceeding with account creation")
        }
        performAccountCreation(with: signUpData)
    }
    
    func signUpWithGoogle() {
        validationError = nil
        performGoogleSignUp()
    }
    
    private func performGoogleSignUp() {
        resultState = .loading
        print("[SignUpViewModel] Starting Google sign-up process")
        
        googleSignInUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("[SignUpViewModel] Google sign-up completed successfully")
                    case .failure(let error):
                        print("[SignUpViewModel] Google sign-up failed: \(error.localizedDescription)")
                        self?.handleSignUpError(error)
                    }
                },
                receiveValue: { [weak self] customerResponse in
                    print("[SignUpViewModel] Google sign-up successful for: \(customerResponse.customer?.email ?? "UNKOWN")")
                    self?.handleSignUpSuccess(customerResponse)
                }
            )
            .store(in: &cancellables)
    }
    
    private func performAccountCreation(with signUpData: SignUpData) {
        resultState = .loading
        print("[SignUpViewModel] Starting account creation process")
        
        createAccountUseCase.execute(signUpData: signUpData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("[SignUpViewModel] Account creation completed successfully")
                    case .failure(let error):
                        print("[SignUpViewModel] Account creation failed: \(error.localizedDescription)")
                        self?.handleSignUpError(error)
                    }
                },
                receiveValue: { [weak self] customerResponse in
                    print("[SignUpViewModel] Account created for: \(customerResponse.customer?.email ?? "UNKNOWN")")
                    self?.handleSignUpSuccess(customerResponse)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleSignUpSuccess(_ customerResponse: CustomerResponse) {
        resultState = .success(customerResponse)
        print("[SignUpViewModel] Sign up state updated to success")
        clearForm()
    }
    
    private func handleSignUpError(_ error: Error) {
        if let authError = error as? AuthError {
            print("[SignUpViewModel] Handling AuthError: \(authError)")
            resultState = .failure(authError.localizedDescription)
        } else {
            print("[SignUpViewModel] Handling generic error: \(error)")
            let errorMessage = getGenericErrorMessage(for: error)
            resultState = .failure(errorMessage)
        }
        print("[SignUpViewModel] Sign up state updated to failure")
    }
    
    private func getGenericErrorMessage(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please check your network settings."
        case NSURLErrorTimedOut:
            return "Request timed out. Please try again."
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            return "Cannot connect to server. Please try again later."
        default:
            if error.localizedDescription.contains("email") &&
               error.localizedDescription.contains("already") {
                return "This email is already registered. Please use a different email or try logging in."
            }
            return error.localizedDescription
        }
    }

    private func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        password = ""
        print("[SignUpViewModel] Form cleared")
    }
}
