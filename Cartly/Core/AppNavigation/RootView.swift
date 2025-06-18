//
//  RootView.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var reachability = NetworkMonitor()
    
    var body: some View {
        Group {
            if reachability.isConnected {
                switch router.rootState {
                case .splash:
                    SplashScreen()
                case .authentication:
                    AuthFlow()
                case .main:
                    MainFlow()
                }
            } else {
                NoConnectionScreen()
            }
        }
        .onChange(of: reachability.isConnected) { _,connected in
            router.updatePathIfConnected(connected)
        }
        .environmentObject(router)
        .environmentObject(reachability)
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
