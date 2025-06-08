//
//  SplashViewModel.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import Combine
import SwiftUI

final class SplashViewModel: ObservableObject {

    func navigate(router: AppRouter) {
        router.setRoot(.main)
    }
}

#if false
        if UserDefaultsManager.getLoginStatus() {
            router.setRoot(.main)
        } else {
            router.setRoot(.authentication)
        }
#endif

