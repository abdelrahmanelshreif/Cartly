//
//  AppState.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

enum Route: Hashable {
    case Login
    case Signup
    case Products(Int64, String)
    case productDetail(Int64)
    case productDetailFromCart(productId: Int64, isFromCart:Bool ,variantId: Int64)
    case Cart
    case Search
    case settings
    case orders
    case OrderCompletingScreen(CartMapper)
}

enum AuthRoute: Hashable {
    case Login
    case Signup
}

enum RootState {
    case splash
    case authentication
    case main
}
