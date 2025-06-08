//
//  CartlyApp.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 25/5/25.
//

import Combine
import FirebaseCore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // Add this method to handle Google Sign-In URL
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct CartlyApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    lazy var viewModel = HomeViewModel(
        getBrandUseCase: GetBrandsUseCase(
            repository: RepositoryImpl(
                remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
            )
        )
    )

    var body: some Scene {
        WindowGroup {
            NavigationView {
//                ProductDetailsView(productId: 8_135_647_985_847)
                WishlistScreen()
            }
            // Add onOpenURL modifier to handle Google Sign-In callback
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
