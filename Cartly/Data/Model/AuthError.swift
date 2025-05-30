//
//  AuthError.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

enum AuthError : Error{
    case signupFailed
    case shopifySignUpFailed
    case firebaseSignUpFailed
    case signinFalied
    case userNotFound
}

