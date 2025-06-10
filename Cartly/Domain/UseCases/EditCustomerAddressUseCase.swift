//
//  EditCustomerAddressUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//

import Foundation
import Combine

protocol EditCustomerAddressUseCaseProtocol {
    func execute(customerID: Int64, address: Address) -> AnyPublisher<Address, Error>
}

class EditCustomerAddressUseCase: EditCustomerAddressUseCaseProtocol {
    private let repository: CustomerAddressRepositoryProtocol

    init(repository: CustomerAddressRepositoryProtocol) {
        self.repository = repository
    }

    func execute(customerID: Int64, address: Address) -> AnyPublisher<Address, Error> {
        return repository.editAddress(for: customerID, address: address)
    }
}
