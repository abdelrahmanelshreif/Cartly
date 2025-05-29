//
//  AuthRepositoryImpl.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Foundation

class AuthRepositoryImpl: AuthRepositoryProtocol{
    
    typealias CredentialsType = EmailCredentials
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    typealias Token = String
    
    let firebaseAuthClient: FirebaseServiceProtocol
    let shopifyAuthClient: ShopifyServices
    
    static let shared = AuthRepositoryImpl()
    
    private init(){
        firebaseAuthClient = FirebaseServices()
        shopifyAuthClient = ShopifyServices()
    }
    
    func signup(signUpData: SignUpData) async throws -> Customer {
        do{
            guard let customer = try await shopifyAuthClient.signup(userData: signUpData) else{
                throw AuthError.shopifySignUpFailed
            }
            guard let _ = try await firebaseAuthClient.signup(email: signUpData.email, password: signUpData.password) else{
                throw AuthError.firebaseSignUpFailed
            }
            return customer
        }catch(let error){
            throw error
        }
    }

    func signIn(credentials: EmailCredentials) async throws -> String {
        do{
            guard let email = try? await firebaseAuthClient.signIn(email: credentials.email, password: credentials.password) else{
                throw AuthError.signinFalied
            }
            return email
        }catch(let error){
            throw error
        }
    }
    
    
    func signOut() throws {
        do{
            try firebaseAuthClient.signOut()
        }catch(let error){
            throw error
        }
        
    }
}
