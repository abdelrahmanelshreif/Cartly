//
//  RootView.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    var body: some View {
        Group {
            switch router.rootState {
            case .splash:
                SplashScreen()
            case .authentication:
                AuthFlow()
            case .main:
                MainFlow()
            }
        }
        .environmentObject(router)
        .alert(
            "Login Required",
            isPresented: Binding(get: {
                router.alert != nil
            }, set: { _ in
                router.alert = nil
            }),
            presenting: router.alert
        ){ _ in
            Button("Cancel", role: .cancel){}
            Button("Login"){
                router.setRoot(.authentication)
            }
        }message: { alert in
            Text(alert.message)
        }
    }
}


/*
 
 NavigationStack(path: $router.path) {
     SplashScreen()
         .navigationDestination(for: AppRoute.self) { route in
             switch route {
             case .Splash:
                 SplashScreen()
             case .Login:
                 LoginView().navigationBarBackButtonHidden(true)
             case .Signup:
                 SignupView().navigationBarBackButtonHidden(true)
             case .Main:
                 HomeTabView().navigationBarBackButtonHidden(true)
             case let .Products(brandId):
                 ProductScreen(brandId: brandId)
             case .Favourite:
                 MyFavouriteScreen()
             }
         }
         .alert(
             "Login Required",
             isPresented: Binding(
                 get: { router.alert != nil },
                 set: { _ in router.alert = nil }
             ),
             presenting: router.alert
         ) { _ in
             Button("Cancel", role: .cancel) {
             }
             Button("Login") {
                 router.push(.Login)
             }
         } message: { alert in
             Text(alert.message)
         }
 }
 .environmentObject(router)
 
 */
