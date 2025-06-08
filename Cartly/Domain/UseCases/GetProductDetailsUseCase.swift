//
//  GetProductDetails.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//
import Combine
import Foundation

protocol GetProductDetailsUseCaseProtocol{
    func execute(productId:Int64) -> AnyPublisher<Result<Product?,Error>,Never>
}

class GetProductDetailsUseCase : GetProductDetailsUseCaseProtocol{
  
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
  
    func execute(productId: Int64) -> AnyPublisher<Result<Product?, Error>, Never> {
        return repository.getSingleProduct(for: productId)
            .map{
                Result.success($0?.product)
            }
            .catch{ error in
                Just(Result.failure(error))
            }
            .eraseToAnyPublisher()
        
    }
    
}
