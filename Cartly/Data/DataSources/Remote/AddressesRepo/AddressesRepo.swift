//
//  AddressesRepo.swift
//  Cartly
//
//  Created by Khalid Amr on 04/06/2025.
//

import Foundation
import Combine
import Alamofire


final class CustomerAddressRepository: CustomerAddressRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchAddresses(for customerID: Int64) -> AnyPublisher<[Address], Error> {
        let request = APIRequest(withPath: "/customers/\(customerID)/addresses.json")
        return networkService.request(request, responseType: AddressesListResponse.self)
            .tryMap { $0?.addresses ?? [] }
            .eraseToAnyPublisher()
    }
    
    func addAddress(for customerID: Int64, address: Address) -> AnyPublisher<Address, Error> {
        let addressDict: [String: Any] = [
            "address1": address.address1 ?? "",
            "address2": address.address2 ?? "",
            "city": address.city ?? "",
            "company": address.company ?? "",
            "first_name": address.firstName ?? "",
            "last_name": address.lastName ?? "",
            "phone": address.phone ?? "",
            "province": address.province ?? "",
            "country": address.country ?? "",
            "zip": address.zip ?? "",
            "name": address.name ?? "",
            "province_code": address.provinceCode ?? "",
            "country_code": address.countryCode ?? "",
            "country_name": address.countryName ?? "",
            "default": address.isDefault ?? false
        ]
        
        let body: [String: Any] = [
            "address": addressDict
        ]
        
        let request = APIRequest(
            withMethod: .POST,
            withPath: "/customers/\(customerID)/addresses.json",
            withParameters: body
        )
        
        if let encoded = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let jsonString = String(data: encoded, encoding: .utf8) {
            print(" JSON to send:\n\(jsonString)")
        }

        return networkService.request(request, responseType: CustomerAddressResponse.self)
            .handleEvents(receiveOutput: { response in
                print(" Shopify responded: \(String(describing: response))")
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(" Shopify request failed: \(error.localizedDescription)")
                }
            })
            .tryMap { $0?.customerAddress ?? address }
            .eraseToAnyPublisher()
    }


    
    func editAddress(for customerID: Int64, address: Address) -> AnyPublisher<Address, Error> {
        guard let addressID = address.id else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let addressDict: [String: Any] = [
            "id":addressID,
            "address1": address.address1 ?? "",
            "address2": address.address2 ?? "",
            "city": address.city ?? "",
            "first_name": address.firstName ?? "",
            "last_name": address.lastName ?? "",
            "phone": address.phone ?? "",
            "province": address.province ?? "",
            "zip": address.zip ?? "",
            "default": address.isDefault ?? false
        ]
        let body = ["address": addressDict]
        let request = APIRequest(
            withMethod: .PUT,
            withPath: "/customers/\(customerID)/addresses/\(addressID).json",
            withParameters: body
        )
        return networkService.request(request, responseType: CustomerAddressResponse.self)
            .tryMap { $0?.customerAddress ?? address }
            .eraseToAnyPublisher()
    }

    func deleteAddress(for customerID: Int64, addressID: Int64) -> AnyPublisher<Void, Error> {
        let request = APIRequest(
            withMethod: .DELETE,
            withPath: "/customers/\(customerID)/addresses/\(addressID).json"
        )
        return networkService.request(request, responseType: EmptyResponse.self)
            .map { _ in () }
            .catch { error -> AnyPublisher<Void, Error> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setDefaultAddress(for customerID: Int64, addressID: Int64) -> AnyPublisher<Address, Error> {
        let request = APIRequest(
            withMethod: .PUT,
            withPath: "/customers/\(customerID)/addresses/\(addressID)/default.json"
        )
        return networkService.request(request, responseType: CustomerAddressResponse.self)
            .tryMap {
                var fallback = Address(
                    address1: nil, address2: nil, city: nil,
                    country: nil, countryCode: nil, countryName: nil,
                    company: nil, firstName: nil,
                    id: addressID, lastName: nil, name: nil,
                    phone: nil, province: nil, provinceCode: nil,
                    zip: nil, isDefault: true
                )
                fallback.customerId = customerID
                return $0?.customerAddress ?? fallback
            }
            .eraseToAnyPublisher()
    }
}


final class CurrencyRepository: CurrencyRepositoryProtocol {
    private let service: CurrencyAPIServiceProtocol

    init(service: CurrencyAPIServiceProtocol) {
        self.service = service
    }

    func getExchangeRate(from: String, to: String) -> AnyPublisher<Double, Error> {
        service.fetchRate(from: from, to: to)
    }
}
