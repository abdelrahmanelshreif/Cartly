//
//  Repository.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 27/5/25.
//

import Combine

class RepositoryImpl: RepositoryProtocol{
    
    private let remoteDataSource: RemoteDataSourceProtocol
    
    init(remoteDataSource: RemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getBrands() -> AnyPublisher<[SmartCollection]?, Error> {
        return remoteDataSource.getBrands()
            .map { $0?.smartCollections ?? [] }
            .eraseToAnyPublisher()
    }
    
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, any Error> {
        return remoteDataSource.getProducts(from: collectionID)
    }
    
    func getSingleProduct(for productId: Int) -> AnyPublisher<SingleProductResponse?, any Error> {
        return remoteDataSource.getSingleProduct(for: productId)
    }
    
    
//    func getCustomers() -> AnyPublisher<[CustomerResponse]?, any Error> {
//        <#code#>
//    }
//
//    func getCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, any Error> {
//        <#code#>
//    }
//
    
}
