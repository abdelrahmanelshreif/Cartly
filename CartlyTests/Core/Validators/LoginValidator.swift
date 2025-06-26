//
//  LoginValidator.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//
import Foundation
@testable import Cartly

class MockLoginValidator: LoginValidatorProtocol {
    
    var validationResultToReturn: ValidationResult = .valid
    
    func validate(_ data: EmailCredentials) -> ValidationResult {
        print("[MockLoginValidator] validate called. Returning: \(validationResultToReturn)")

        return validationResultToReturn
    }
}
