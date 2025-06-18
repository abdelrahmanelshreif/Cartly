//
//  UpdateQuantityUseCase.swift
//  Cartly
//
//  Created by Khaled Mustafa on 18/06/2025.
//

import Combine

class UpdateQuantityUseCase {
    let repo: RepositoryProtocol
    init(repo: RepositoryProtocol) {
        self.repo = repo
    }

    func execute(updateQuantityInventoryEntity: UpdateQuantityEntity) -> AnyPublisher<[CartMapper], Error> {
        repo.updateItemQuantity(updateQuantityEntity: updateQuantityInventoryEntity)
            .handleEvents(
                receiveOutput: { success in
                    print("AddToCart completed with result: \(success)")
                },
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("AddToCart failed with error: \(error)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
