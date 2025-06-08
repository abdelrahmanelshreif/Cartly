//
//  GetUserWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 6/6/25.
//

import Combine

protocol GetWishlistUseCaseProtocol {
    func execute(userId:String) -> AnyPublisher<[WishlistProduct]?, Error>
}

class GetUserWishlistUseCase : GetWishlistUseCaseProtocol {
 
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String) -> AnyPublisher<[WishlistProduct]?, any Error> {
        return repository.getWishlistProductsForUser(whoseId: userId )
    }
    
}
