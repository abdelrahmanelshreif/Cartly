//
//  AddCustomerAddressUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//

import Foundation
import Combine

protocol AddCustomerAddressUseCaseProtocol {
    func execute(customerID: Int64, address: Address) -> AnyPublisher<Address, Error>
}

class AddCustomerAddressUseCase: AddCustomerAddressUseCaseProtocol {
    private let repository: CustomerAddressRepositoryProtocol

    init(repository: CustomerAddressRepositoryProtocol) {
        self.repository = repository
    }

    func execute(customerID: Int64, address: Address) -> AnyPublisher<Address, Error> {
        return repository.addAddress(for: customerID, address: address)
    }
}
