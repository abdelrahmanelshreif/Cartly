//
//  EmailCredentials.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

enum LoginCredentials{
    case email(credentials: EmailCredentials)
    case google
}

struct EmailCredentials : Codable{
    let email:String
    let password:String
}
