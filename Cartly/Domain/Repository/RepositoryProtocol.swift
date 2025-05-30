//
//  RepositoryProtocol.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 27/5/25.
//

import Combine

protocol RepositoryProtocol{
    func getBrands() -> AnyPublisher<[SmartCollection]?, Error>
    
    func getProducts(for collectionID: Int) -> AnyPublisher<[Product]?, Error>
}
 
