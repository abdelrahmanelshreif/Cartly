//
//  SignUpData.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

struct SignUpData : Codable{
    let firstname:String
    let lastname:String
    let email:String
    let password:String
    let passwordConfirm:String
    let sendinEmailVerification:Bool
}
