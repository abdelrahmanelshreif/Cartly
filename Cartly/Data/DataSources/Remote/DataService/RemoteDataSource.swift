//
//  RemoteDataSource.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import Combine

protocol RemoteDataSourceProtocol {
    func getBrands() -> AnyPublisher<SmartCollectionsResponse, Error>

    func getProducts(from collection_id: Int) -> AnyPublisher<[Product], Error>
    
}

final class RemoteDataSourceImpl: RemoteDataSourceProtocol {
    func getProducts(from collection_id: Int) -> AnyPublisher<[Product], any Error> {
        let path = "/products.json?collection_id=\(collection_id)"
        let apiRequest = APIRequest(withPath: path)

        return networkService.request(apiRequest, responseType: ProductListResponse.self)
            .map {
                $0.products
            }
            .eraseToAnyPublisher()
    }

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getBrands() -> AnyPublisher<SmartCollectionsResponse, Error> {
        let request = APIRequest(
            withPath: "/smart_collections.json"
        )
        return networkService.request(request, responseType: SmartCollectionsResponse.self)
    }
}
