//
//  AdsNetworkService.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine

protocol AdsNetworkServiceProtocol {
    func fetchAdsImages() -> AnyPublisher<[AdImage], Error>
}

class AdsNetworkService: AdsNetworkServiceProtocol {
    func fetchAdsImages() -> AnyPublisher<[AdImage], Error> {
        let url = URL(string: "https://683b1ce243bb370a8674c5d2.mockapi.io/adsImageData")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [AdImage].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
