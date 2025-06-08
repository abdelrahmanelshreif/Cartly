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
        
            return true
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
                AddressesView(viewModel: AddressesViewModel(fetchAddressesUseCase: FetchCustomerAddressesUseCase(repository: CustomerAddressRepository(networkService: AlamofireService())), addAddressUseCase: AddCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService())), setDefaultAddressUseCase: SetDefaultCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService()))))           }
        }
    }
}

