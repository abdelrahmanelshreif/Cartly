import Combine
import SwiftUI

final class SplashViewModel: ObservableObject {
    func navigate(router: AppRouter) {
        if UserDefaultsManager.getLoginStatus() {
            router.setRoot(.main)
        } else {
            router.setRoot(.authentication)
        }
    }
}
