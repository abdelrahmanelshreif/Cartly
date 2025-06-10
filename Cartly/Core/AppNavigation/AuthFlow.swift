//
//  AuthFlow.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import SwiftUI
import Combine
struct AuthFlow: View{
    @EnvironmentObject var router: AppRouter
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack(path:$router.path){
            if showLogin {
                LoginView()
            }else {
                SignupView()
            }
        }
        .onAppear {
            showLogin = true
        }
    }
}
