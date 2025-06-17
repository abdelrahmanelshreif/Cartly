//
//  MainFlow.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import Combine
import SwiftUI

struct MainFlow: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeTabView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .Login:
                        LoginView()
                    case .Signup:
                        SignupView()
                    case let .Products(brandId, brandTitle):
                        ProductScreen(brandId: brandId, brandTitle: brandTitle)
                    case let .productDetail(productId):
                        ProductDetailsView(productId:productId)
                    case let .productDetailFromCart(productId, isCartSource ,variantId):
                        ProductDetailsView(productId: productId, isFromCart: isCartSource, varientId: variantId)
                    case .Cart:
                        CartScreen()
                    case .Search:
                        SearchScreen()
                    case .settings:
                        SettingsScreen()
                    case .orders:
                        OrdersScreen()
                    case .adresses:
                        ChangeAddressView()
                    case .OrderCompletingScreen(let cart):
                        OrderCompletingScreen(cart: cart)
                    }
                }
        }
    }
}
