//
//  RemoveProductFromWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 6/6/25.
//

import Combine

protocol RemoveProductFromWishlistUseCaseProtocol {
    func execute(userId:String , productId:String) -> AnyPublisher<Void, Error>
}

class RemoveProductFromWishlistUseCase : RemoveProductFromWishlistUseCaseProtocol {

    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(userId: String, productId: String) -> AnyPublisher<Void, any Error> {
        repository.removeWishlistProductForUser(whoseId: userId, withProduct: productId)
    }
    
}
