import Foundation
import Combine
import FirebaseAuth
	
protocol FirebaseShopifyLoginUseCaseProtocol {
    func execute(credentials: LoginCredentials) -> AnyPublisher<ResultState<CustomerResponse?>, Never>
}

class FirebaseShopifyLoginUseCase: FirebaseShopifyLoginUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let customerRepository: RepositoryProtocol
    private let userSessionService: UserSessionServiceProtocol

    init(
        authRepository: AuthRepositoryProtocol,
        customerRepository: RepositoryProtocol,
        userSessionService: UserSessionServiceProtocol
    ) {
        self.authRepository = authRepository
        self.customerRepository = customerRepository
        self.userSessionService = userSessionService
    }

    func execute(credentials: LoginCredentials) -> AnyPublisher<ResultState<CustomerResponse?>, Never> {

        let loginOperation = getFirebaseUserPublisher(for: credentials)
            .flatMap { user -> AnyPublisher<CustomerResponse?, Error> in
                guard let user = user else {
                    return Fail(error: AuthError.firebaseloginFailed).eraseToAnyPublisher()
                }
                return self.getShopifyCustomer(for: user.email!)
            }
            .map { customerResponse -> ResultState<CustomerResponse?> in
                .success(customerResponse)
            }
            .catch { error in
                Just(.failure(error.localizedDescription))
            }

        return Just(ResultState.loading)
            .append(loginOperation)
            .eraseToAnyPublisher()
    }

    private func getFirebaseUserPublisher(for credentials: LoginCredentials) -> AnyPublisher<User?, Error> {
        switch credentials {
        case .email(let emailCreds):
            return authRepository.signIn(email: emailCreds.email, password: emailCreds.password)
        case .google:
            return authRepository.signInWithGoogle()
        }
    }

    private func getShopifyCustomer(for email: String) -> AnyPublisher<CustomerResponse?, Error> {
        return customerRepository.getCustomers()
            .flatMap { [weak self] customersResponse -> AnyPublisher<CustomerResponse?, Error> in
                guard let self = self else {
                    return Fail(error: AuthError.userNotFound).eraseToAnyPublisher()
                }

                guard let customers = customersResponse?.customers else {
                    return Fail(error: AuthError.customerNotFoundAtShopify).eraseToAnyPublisher()
                }

                if let customer = customers.first(where: { $0.email.lowercased() == email.lowercased() }) {
                    self.userSessionService.saveUserSession(customer)
                    return Just(CustomerResponse(customer: customer))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: AuthError.customerNotFoundAtShopify).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
