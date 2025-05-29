//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

protocol AuthRepositoryProtocol{
    
    associatedtype UserType : Codable
    associatedtype CredentialsType : Codable
    associatedtype SignUpDataType : Codable
    associatedtype Token : Codable
    
    func signIn(credentials:CredentialsType) async throws -> Token
    
    func signup(signUpData:SignUpDataType) async throws -> UserType
    
    func signOut() throws

}
