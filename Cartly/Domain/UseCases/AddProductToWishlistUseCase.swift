//
//  AddProductToWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 6/6/25.
//

import Combine

protocol AddProductToWishlistUseCaseProtocol {
    func execute(userId:String , product:WishlistProduct) -> AnyPublisher<Void, Error>
}

class AddProductToWishlistUseCase : AddProductToWishlistUseCaseProtocol {

    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String, product: WishlistProduct) -> AnyPublisher<Void, any Error> {
        return repository.addWishlistProductForUser(whoseId: userId, withProduct: product)
    }
}
