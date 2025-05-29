//
//  Address.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Foundation

// MARK: - Address Model
struct Address: Codable {
    let address1: String?
    let address2: String?
    let city: String?
    let country: String?
    let countryCode: String?
    let countryName: String?
    let company: String?
    let customerId: Int64?
    let firstName: String?
    let id: Int64?
    let lastName: String?
    let name: String?
    let phone: String?
    let province: String?
    let provinceCode: String?
    let zip: String?
    
    enum CodingKeys: String, CodingKey {
        case address1
        case address2
        case city
        case country
        case countryCode = "country_code"
        case countryName = "country_name"
        case company
        case customerId = "customer_id"
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case name
        case phone
        case province
        case provinceCode = "province_code"
        case zip
    }
}
