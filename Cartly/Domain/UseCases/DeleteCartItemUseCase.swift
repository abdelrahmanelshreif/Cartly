//
//  DeleteCartItemUseCase.swift
//  Cartly
//
//  Created by Khaled Mustafa on 15/06/2025.
//

import Combine

final class DeleteCartItemUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(draftOrderID: Int64, itemID: Int64) -> AnyPublisher<[CartMapper], Error> {
        return repository.deleteExistingDraftOrder(draftOrderID: draftOrderID, itemID: itemID)
            .handleEvents(
                receiveSubscription: { _ in
                    print("Starting deletion process for item \(itemID) in draft order \(draftOrderID)")
                },
                receiveOutput: { cartMappers in
                    if cartMappers.isEmpty {
                        print("Cart is now empty after deletion")
                    } else {
                        print("Cart updated with \(cartMappers.count) remaining orders")
                    }
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Deletion completed successfully")
                    case let .failure(error):
                        print("Deletion failed with error: \(error)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
