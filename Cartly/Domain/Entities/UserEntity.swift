//
//  UserEntity.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

struct UserEntity : Identifiable{
    let id: String?
    let email: String?
    let emailVerificationStatus: Bool
    let sessionStatus: Bool
}
