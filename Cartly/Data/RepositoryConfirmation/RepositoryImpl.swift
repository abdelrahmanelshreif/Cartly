//
//  Repository.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 27/5/25.
//

import Combine

class RepositoryImpl: RepositoryProtocol{
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, any Error> {
        return remoteDataSource.getProducts(from: collectionID)
    }
    
    private let remoteDataSource: RemoteDataSourceProtocol

        init(remoteDataSource: RemoteDataSourceProtocol) {
            self.remoteDataSource = remoteDataSource
        }

        func getBrands() -> AnyPublisher<[SmartCollection]?, Error> {
            return remoteDataSource.getBrands()
                .map { $0?.smartCollections ?? [] }
                .eraseToAnyPublisher()
        }
}
