//
//  CartlyApp.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 25/5/25.
//

import FirebaseCore
import SwiftUI
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        // Test your auth implementation
            testAuthFlow()
            
            return true
        }
        
        private func testAuthFlow() {
            print("🧪 Testing Auth Flow...")
            
            // Create test data
            let testEmail = "tees2t@example.com"
            let signUpData = SignUpData(
                firstname: "Test",
                lastname: "User",
                email: testEmail,
                password: "password123",
                phone:"+201119498802",
                passwordConfirm: "password123",
                sendinEmailVerification: true
            )
            
            // Test sign upN
            AuthRepositoryImpl.shared.signup(signUpData: signUpData)
                .flatMap { customerResponse -> AnyPublisher<String?, Error> in
                    print("✅ Sign up successful! Customer: \(customerResponse?.customer.email ?? "NA")")
                    
                    // Now test sign in
                    let credentials = EmailCredentials(
                        email: testEmail,
                        password: "password123"
                    )
                    return AuthRepositoryImpl.shared.signIn(credentials: credentials)
                }
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("✅ Full auth flow completed!")
                        case .failure(let error):
                            print("❌ Auth flow failed: \(error)")
                        }
                    },
                    receiveValue: { token in
                        print("🔑 Final token: \(token ?? "NA")")
                    }
                )
                .store(in: &cancellables)
        }
    
}

@main
struct CartlyApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let viewModel = ProductsViewModel(useCase: GetProductsUseCase(repository: RepositoryImpl(remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()))))


    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProductsListView(viewModel: viewModel, collectionID: 307654197431)
            }
        }
    }
}

