//
//  SignUpValidator.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//

import Foundation

protocol SignUpValidatorProtocol {
    func validate(_ data: SignUpData) -> ValidationResult
}

class SignUpValidator : SignUpValidatorProtocol{
    
    func validate(_ data: SignUpData) -> ValidationResult {
        
        if data.firstname.trimmingCharacters(in: .whitespaces).isEmpty {
            return .invalid(.emptyFirstName)
        }
        
        if data.lastname.trimmingCharacters(in: .whitespaces).isEmpty {
            return .invalid(.emptyLastName)
        }
        
        if !GeneralValidator.isValidEmail(data.email) {
            return .invalid(.invalidEmail)
        }
        
        if !GeneralValidator.isValidPhone(data.phone!) {
            return .invalid(.invalidPhone)
        }
        
        if data.password!.count < 6 {
            return .invalid(.weakPassword)
        }
        
        return .valid
    }
}


