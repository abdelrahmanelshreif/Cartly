//
//  CartlyApp.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 25/5/25.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
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
                ProductsListView(viewModel: viewModel, collectionID: 307654197431)
            }
        }
    }
}

// import SwiftUI
// import Firebase
//
// @main
// struct CartlyApp: App {
//    let persistenceController = PersistenceController.shared
//
//    init(){
//        FirebaseApp.configure()
//    }
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//        }
//    }
// }
//
