//
//  FetchCustomerAddressesUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//
import Foundation
import Combine

protocol FetchCustomerAddressesUseCaseProtocol {
    func execute(customerID: Int64) -> AnyPublisher<[Address], Error>
}

class FetchCustomerAddressesUseCase: FetchCustomerAddressesUseCaseProtocol {
    private let repository: CustomerAddressRepositoryProtocol

    init(repository: CustomerAddressRepositoryProtocol) {
        self.repository = repository
    }

    func execute(customerID: Int64) -> AnyPublisher<[Address], Error> {
        return repository.fetchAddresses(for: customerID)
    }
}
