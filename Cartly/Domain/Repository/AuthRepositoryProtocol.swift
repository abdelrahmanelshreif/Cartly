//
//  AuthRepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//
import Combine
protocol AuthRepositoryProtocol{
    
    associatedtype UserType : Codable
    associatedtype CredentialsType : Codable
    associatedtype SignUpDataType : Codable
    associatedtype Token : Codable
    
    func signIn(credentials:CredentialsType) async throws -> AnyPublisher<Token,Error>
    func signup(signUpData:SignUpDataType) async throws -> AnyPublisher<UserType,Error>
    func signOut() -> AnyPublisher<Void,Error>

}
