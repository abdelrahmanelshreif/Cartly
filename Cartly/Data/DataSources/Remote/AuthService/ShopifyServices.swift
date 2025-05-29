//
//  ShopifyServicesProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//
protocol ShopifyServicesProtocol{
    
    associatedtype SignUpDataType : Codable
    associatedtype UserType : Codable
    func signup(userData : SignUpDataType) async throws -> UserType?
}


final class ShopifyServices: ShopifyServicesProtocol{
    
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    typealias Credentials = EmailCredentials
    
    func signup(userData: SignUpData) async throws -> Customer? {
        /// 1- Shopify Post request with alamofire
        /// 2- if step 1 success then store Customer_ID in keyChain
        /// 3- login with firebase -> firebaseAuthClient.signIn(email, password).
        ///
        return nil 
    }
}
