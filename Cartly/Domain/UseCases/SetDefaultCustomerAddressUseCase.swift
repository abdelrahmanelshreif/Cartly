//
//  SetDefaultCustomerAddressUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//

import Foundation
import Combine

protocol SetDefaultCustomerAddressUseCaseProtocol {
    func execute(customerID: Int64, addressID: Int64) -> AnyPublisher<Address, Error>
}

class SetDefaultCustomerAddressUseCase: SetDefaultCustomerAddressUseCaseProtocol {
    private let repository: CustomerAddressRepositoryProtocol

    init(repository: CustomerAddressRepositoryProtocol) {
        self.repository = repository
    }

    func execute(customerID: Int64, addressID: Int64) -> AnyPublisher<Address, Error> {
        return repository.setDefaultAddress(for: customerID, addressID: addressID)
    }
}
