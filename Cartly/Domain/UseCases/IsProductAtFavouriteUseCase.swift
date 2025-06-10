//
//  IsProductAtFavouriteUseCase.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 6/6/25.
//


import Combine

protocol IsProductAtFavouriteUseCaseProtocol {
    func execute(userId:String , productId:String) -> AnyPublisher<Bool, Error>
}

class IsProductAtFavouriteUseCase : IsProductAtFavouriteUseCaseProtocol {

    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String, productId: String) -> AnyPublisher<Bool, any Error> {
        repository.isProductInWishlist(withProduct: productId, forUser: userId)
    }
    
   
}
