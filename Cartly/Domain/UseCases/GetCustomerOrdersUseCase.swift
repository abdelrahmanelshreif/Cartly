//
//  GetCustomerOrdersUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 17/6/25.
//
import Combine
import Foundation

protocol GetCustomerOrderUseCaseProtocol {
    func execute(customerId: Int64) -> AnyPublisher<[OrderEntity], Error>
}

struct GetCustomerOrdersUseCase: GetCustomerOrderUseCaseProtocol {

    let repository: RepositoryProtocol
    private let mapper: OrderMapperProtocol

    init(
        repository: RepositoryProtocol,
        mapper: OrderMapperProtocol = OrderMapper()
    ) {
        self.repository = repository
        self.mapper = mapper
    }

    func execute(customerId: Int64) -> AnyPublisher<[OrderEntity], Error> {
        return repository.getCustomerOrders(customerId)
            .map { response in
                guard let response = response else {
                    return []
                }
                return self.mapper.mapOrders(from: response)
            }
            .eraseToAnyPublisher()
    }
}
