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
    @Published var resultState: ResulteAuthenticationState<String> = .none
    private var cancellables = Set<AnyCancellable>()
    
    let loginUseCase: FirebaseShopifyLoginUseCaseProtocol
    let loginUsingGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol
    let validator: LoginValidatorProtocol
    
    init(
        loginUseCase: FirebaseShopifyLoginUseCaseProtocol,
        validator: LoginValidatorProtocol,
        loginUsingGoogleUseCase: AuthenticatingUserWithGoogleUseCaseProtocol
    ) {
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
        resultState = .loading
        
        loginUsingGoogleUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("[LoginViewModel] Google login completed successfully")
                    case .failure(let error):
                        print("[LoginViewModel] Google login failed: \(error.localizedDescription)")
                        self?.handleLoginError(error)
                    }
                },
                receiveValue: { [weak self] customerResponse in
                    print("[LoginViewModel] Google login successful for: \(customerResponse.customer?.email ?? "UNKOWN")")
                    self?.handleLoginSuccess(customerResponse)
                }
            )
            .store(in: &cancellables)
    }

    private func performLogin(with credentials: EmailCredentials) {
        resultState = .loading
        
        loginUseCase.execute(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("[LoginViewModel] Email login completed successfully")
                    case .failure(let error):
                        print("[LoginViewModel] Email login failed: \(error.localizedDescription)")
                        self?.handleLoginError(error)
                    }
                },
                receiveValue: { [weak self] customerResponse in
                    print("[LoginViewModel] Email login successful for: \(customerResponse.customer?.email ?? "")")
                    self?.handleLoginSuccess(customerResponse)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleLoginSuccess(_ customerResponse: CustomerResponse) {
        let userName = customerResponse.customer?.firstName ?? "User"
        resultState = .success(userName)
        print("[LoginViewModel] Login state updated to success with name: \(userName)")
    }
    
    private func handleLoginError(_ error: Error) {
        if let authError = error as? AuthError {
            print("[LoginViewModel] Handling AuthError: \(authError)")
            resultState = .failure(authError.localizedDescription)
        } else {
            print("[LoginViewModel] Handling generic error: \(error)")
            let errorMessage = getGenericErrorMessage(for: error)
            resultState = .failure(errorMessage)
        }
        
        print("[LoginViewModel] Login state updated to failure")
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
            return error.localizedDescription
        }
    }
}
