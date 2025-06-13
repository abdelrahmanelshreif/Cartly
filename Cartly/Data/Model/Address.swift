//
//  Address.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Foundation

// MARK: - Address Wrapper
struct AddressWrapper: Codable {
    let address: Address
}

// MARK: - Address Response Wrapper
struct CustomerAddressResponse: Codable {
    let customerAddress: Address

    enum CodingKeys: String, CodingKey {
        case customerAddress = "customer_address"
    }
}

// MARK: - Address List Response
struct AddressesListResponse: Codable {
    let addresses: [Address]
}


// MARK: - Address Model
struct Address: Codable {
    var address1: String?
    var address2: String?
    var city: String?
    var country: String?
    var countryCode: String?
    var countryName: String?
    var company: String?
    var customerId: Int64? = nil
    var firstName: String?
    var id: Int64?
    var lastName: String?
    var name: String?
    var phone: String?
    var province: String?
    var provinceCode: String?
    var zip: String?
    var isDefault: Bool?
    
    enum CodingKeys: String, CodingKey {
        case address1
        case address2
        case city
        case country
        case countryCode = "country_code"
        case countryName = "country_name"
        case company
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case name
        case phone
        case province
        case provinceCode = "province_code"
        case zip
        case isDefault = "default"

    }
}
struct DeleteErrorResponse: Codable {
    let errors: DeleteError

    struct DeleteError: Codable {
        let base: [String]
    }
}

struct EmptyResponse: Codable {}
