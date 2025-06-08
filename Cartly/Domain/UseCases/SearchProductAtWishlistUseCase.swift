//
//  SearchProductAtWishlistUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

import Combine

protocol SearchProductAtWishlistUseCaseProtocol {
    func execute(userId:String , productId:String) -> AnyPublisher<Bool, Error>
}

class SearchProductAtWishlistUseCase : SearchProductAtWishlistUseCaseProtocol {

    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(userId: String, productId: String) -> AnyPublisher<Bool, any Error> {
        return repository.isProductInWishlist(withProduct: productId, forUser: userId)
    }
    
}
