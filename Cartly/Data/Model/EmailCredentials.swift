//
//  EmailCredentials.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import UIKit

enum LoginCredentials{
    case email(credentials: EmailCredentials)
    case google(presenting: UIViewController)
}
struct EmailCredentials : Codable{
    let email:String
    let password:String
}
