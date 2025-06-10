//
//  ValidationError.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//

import Foundation

enum ValidationError: LocalizedError {
    case emptyFirstName
    case emptyLastName
    case invalidEmail
    case invalidPhone
    case weakPassword
    
    var errorDescription: String? {
        switch self {
        case .emptyFirstName: return "First name is required"
        case .emptyLastName: return "Last name is required"
        case .invalidEmail: return "Please enter a valid email"
        case .invalidPhone: return "Please enter a valid phone number"
        case .weakPassword: return "Password must be at least 6 characters"
        }
    }
}

