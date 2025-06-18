//
//  NavigationManager.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import Combine
import SwiftUI

class AppRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Published var rootState: RootState = .splash
    @Published var alert: AlertContent?
    private var lastKnownPath: NavigationPath = NavigationPath()

    struct AlertContent {
        let title: String
        let message: String
    }
    
    func setRoot(_ state: RootState) {
        rootState = state
        path.removeLast(path.count)
    }
    
    func push<T: Hashable>(_ route: T) {
#if true
        if let route = route as? Route {
            switch route {
            case .Cart:
                if !UserDefaultsManager.getLoginStatus() {
                    print("in App route in cart case and must execute showLoginRequiredAlert")
                    showLoginRequiredAlert()
                    return
                }
            default:
                break
            }
        }
#endif
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    private func showLoginRequiredAlert() {
        alert = AlertContent(
            title: "Login Required",
            message: "Please log in to access this feature"
        )
    }
    
    func updatePathIfConnected(_ connected: Bool) {
        if connected {
            path = lastKnownPath
        } else {
            lastKnownPath = path
            path.removeLast(path.count)
        }
    }
}
