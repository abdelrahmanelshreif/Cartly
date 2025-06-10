//
//  AddressRepositoryProtocol.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//

import Foundation
import Combine

protocol CustomerAddressRepositoryProtocol {
    func fetchAddresses(for customerID: Int64) -> AnyPublisher<[Address], Error>
    func addAddress(for customerID: Int64, address: Address) -> AnyPublisher<Address, Error>
    func editAddress(for customerID: Int64, address: Address) -> AnyPublisher<Address, Error>
    func deleteAddress(for customerID: Int64, addressID: Int64) -> AnyPublisher<Void, Error>
    func setDefaultAddress(for customerID: Int64, addressID: Int64) -> AnyPublisher<Address, Error>
}
protocol CurrencyRepositoryProtocol {
    func getExchangeRate(from: String, to: String) -> AnyPublisher<Double, Error>
}
