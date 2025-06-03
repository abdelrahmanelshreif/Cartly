//
//  AuthError.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case signupFailed
    case shopifySignUpFailed
    case firebaseSignUpFailed
    case signinFalied
    case userNotFound
    case shopifyLoginFailed
    case firebaseloginFailed
    case customerNotFoundAtShopify

    var errorDescription: String? {
        switch self {
        case .signupFailed:
            return "Signup failed. Please try again."
        case .shopifySignUpFailed:
            return "Failed to create account on Shopify."
        case .firebaseSignUpFailed:
            return "Failed to create account on Firebase."
        case .signinFalied:
            return "Signin failed. Please check your credentials."
        case .userNotFound:
            return "User not found."
        case .shopifyLoginFailed:
            return "Unable to fetch customer data from Shopify."
        case .firebaseloginFailed:
            return "Firebase login failed. Please try again."
        case .customerNotFoundAtShopify:
            return "No matching customer found in Shopify."
        }
    }
}
