//
//  LoginValidator.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.
//

import Foundation

protocol LoginValidatorProtocol {
    func validate(_ data: EmailCredentials) -> ValidationResult
}

class LoginValidator : LoginValidatorProtocol{
    
    func validate(_ data: EmailCredentials) -> ValidationResult {
        
        if !GeneralValidator.isValidEmail(data.email) {
            return .invalid(.invalidEmail)
        }

        if data.password.count < 6 {
            return .invalid(.weakPassword)
        }
        return .valid
    }
}


