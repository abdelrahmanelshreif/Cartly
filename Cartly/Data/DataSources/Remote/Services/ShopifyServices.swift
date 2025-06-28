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
        var customerData: [String: Any] = [
            "first_name": userData.firstname,
            "last_name": userData.lastname,
            "email": userData.email,
            "verified_email": true,
            "send_email_welcome": false

        ]
   
        if let password = userData.password {
            customerData["password"] = password
            customerData["password_confirmation"] = userData.passwordConfirm ?? password
        }
        
        let parameters: [String: Any] = ["customer": customerData]
        
        let request = APIRequest.init(withMethod: .POST, withPath: "/customers.json", withParameters: parameters)
        let customer = networkService.request(request, responseType: CustomerResponse.self)
        return customer.eraseToAnyPublisher()
    }
    
}
