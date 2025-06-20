//
//  ShopifyServicesProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 29/5/25.
//

import Combine
import Alamofire

protocol ShopifyServicesProtocol {
    func signup(userData: SignUpData) -> AnyPublisher<CustomerResponse?, Error>
}

final class ShopifyServices: ShopifyServicesProtocol {
    let networkService: NetworkServiceProtocol = AlamofireService()
    
    func signup(userData: SignUpData) -> AnyPublisher<CustomerResponse?, Error> {
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
        let request = APIRequest.init(withMethod: .POST, withPath: "/customers.json", withParameters: parameters)
        let customer = networkService.request(request, responseType: CustomerResponse.self)
        return customer.eraseToAnyPublisher()
    }
    
}
