//
//  GeneralValidator.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 31/5/25.
//
import Foundation

struct GeneralValidator{
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    static func isValidPhone(_ phone: String) -> Bool {
        let cleaned = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleaned.count >= 10 && cleaned.count <= 15
    }
}
