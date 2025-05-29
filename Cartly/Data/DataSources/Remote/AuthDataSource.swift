//
//  AuthDataSource.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Foundation

class AuthDataSource: AuthRepositoryProtocol {
    
    typealias CredentialsType = EmailCredentials
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    
    let firebaseServices = FirebaseServices.shared
    
    func signup(signUpData: SignUpData) async throws -> Customer {
        firebaseServices.signup(email: signUpData.email, password: signUpData.password)
        
    }
    
    func signIn(credentials: EmailCredentials) async throws -> Customer {
        firebaseServices.signIn(email: credentials.email, password: credentials.password)
    }
    
    func signOut() throws {
        do{
            try firebaseServices.signOut()
        }catch(let error){
            throw error
        }
    }
    
    func getCurrentUser() -> Customer? {
        // we will return customer
    }
    
    func isUserVerified() -> Bool {
        return false
    }
    
    func isUserLoggedIn() -> Bool {
        return false
    }

}
