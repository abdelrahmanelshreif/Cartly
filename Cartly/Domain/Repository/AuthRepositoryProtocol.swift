//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//

protocol AuthRepositoryProtocol{
    
    associatedtype UserType : Codable
    associatedtype CredentialsType : Codable
    associatedtype SignUpDataType : Codable
    
    func signIn(credentials:CredentialsType) async throws -> UserType
    func signup(signUpData:SignUpDataType) async throws -> UserType
    func signOut() throws
    func getCurrentUser() -> UserType?
    func isUserVerified() -> Bool
    func isUserLoggedIn() -> Bool
}
