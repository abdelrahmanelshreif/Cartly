//
//  ShopifyServicesProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import Alamofire

protocol ShopifyServicesProtocol {
    associatedtype SignUpDataType: Codable
    associatedtype UserType: Codable
    
    func signup(userData: SignUpDataType) -> AnyPublisher<UserType?, Error>
}

final class ShopifyServices: ShopifyServicesProtocol {
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    typealias Credentials = EmailCredentials
    
    private let baseURL = "https://mad45-ios2-sv.myshopify.com/admin/api/2024-07"
    
    func signup(userData: SignUpData) -> AnyPublisher<Customer?, Error> {
        let endpoint = "\(baseURL)/customers.json"
        
        let parameters: [String: Any] = [
            "customer": [
                "first_name": userData.firstname,
                "last_name": userData.lastname,
                "email": userData.email,
                "phone": userData.phone,
                "verified_email": true,
                "password": userData.password,
                "password_confirmation": userData.password,
                "send_email_welcome": false
            ]
        ]
        
        return AF.request(
            endpoint,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: createHeaders()
        )
        .validate()
        .publishDecodable(type: CustomerResponse.self)
        .value()
        .map { $0.customer }
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
    
    private func createHeaders() -> HTTPHeaders {
        return [
            "X-Shopify-Access-Token": Constants.APIKey,
           
        ]
    }
}
