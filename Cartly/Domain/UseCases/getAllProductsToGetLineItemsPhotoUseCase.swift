//
//  getAllProductsToGetLineItemsPhotoUseCase.swift
//  Cartly
//
//  Created by Khaled Mustafa on 15/06/2025.
//

import Combine

class GetCartItemsWithImagesUseCase{
    private let repository: RepositoryProtocol
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(cartMapper: CartMapper) -> AnyPublisher<[CartMapper], Error>{
        repository.getAllProductsToGetLineItemsPhoto(cartMapper: cartMapper)
            .eraseToAnyPublisher()
    }
}
