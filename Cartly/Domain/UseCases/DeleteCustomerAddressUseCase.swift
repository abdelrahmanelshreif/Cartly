//
//  DeleteCustomerAddressUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 05/06/2025.
//
import Foundation
import Combine

protocol DeleteCustomerAddressUseCaseProtocol {
    func execute(customerID: Int64, addressID: Int64) -> AnyPublisher<Void, Error>
}

class DeleteCustomerAddressUseCase: DeleteCustomerAddressUseCaseProtocol {
    private let repository: CustomerAddressRepositoryProtocol

    init(repository: CustomerAddressRepositoryProtocol) {
        self.repository = repository
    }

    func execute(customerID: Int64, addressID: Int64) -> AnyPublisher<Void, Error> {
        return repository.deleteAddress(for: customerID, addressID: addressID)
    }
}
