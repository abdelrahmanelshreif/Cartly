//
//  AuthError.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Foundation

enum AuthError: LocalizedError {
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

    var debugDescription: String {
        switch self {
        case .signupFailed:
            return "AuthError.signupFailed - General signup failure"
        case .shopifySignUpFailed:
            return "AuthError.shopifySignUpFailed - Shopify API returned error during signup"
        case .firebaseSignUpFailed:
            return "AuthError.firebaseSignUpFailed - Firebase authentication signup failed"
        case .signinFalied:
            return "AuthError.signinFalied - General signin failure"
        case .userNotFound:
            return "AuthError.userNotFound - User does not exist"
        case .shopifyLoginFailed:
            return "AuthError.shopifyLoginFailed - Failed to fetch customers from Shopify"
        case .firebaseloginFailed:
            return "AuthError.firebaseloginFailed - Firebase authentication login failed"
        case .customerNotFoundAtShopify:
            return "AuthError.customerNotFoundAtShopify - Email exists in Firebase but not in Shopify"
        }
    }
}
