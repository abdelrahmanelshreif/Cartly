//
//  FirebaseServices.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import FirebaseAuth

final class FirebaseServices{
    
    static let shared = FirebaseServices()
    
    private init(){}
    
    func signIn(email: String, password: String) async throws -> String? {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.email
        }catch(let error){
            throw error
        }
    }
    
    func signup(email: String, password: String) async throws -> String? {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.email
        }catch(let error){
            throw error
        }
    }
    
    func signOut() throws {
        do{
            try Auth.auth().signOut()
        }catch(let error){
            throw error
        }
    }
    
    func getCurrentUser() -> String? {
        return Auth.auth().currentUser?.email
    }
    
    
}
