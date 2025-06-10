//
//  CurrencyAPIService.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation
import Combine
import Alamofire

protocol CurrencyAPIServiceProtocol {
    func fetchRate(from: String, to: String) -> AnyPublisher<Double, Error>
}

final class CurrencyAPIService: CurrencyAPIServiceProtocol {
    private let apiKey = "cur_live_ngJ4WVweVttrEHfeVbIUrvOHsUMPqhW6oGjVLj7o"
    private let baseURL = "https://api.currencyapi.com/v3/latest"

    func fetchRate(from: String, to: String) -> AnyPublisher<Double, Error> {
        let params: Parameters = [
            "apikey": apiKey,
            "base_currency": from,
            "currencies": to
        ]

        return AF.request(baseURL, parameters: params)
            .validate()
            .publishData()
            .tryMap { response in
                guard let data = response.data else {
                    throw URLError(.badServerResponse)
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔵 Raw JSON:\n\(jsonString)")
                }

                let decoded = try JSONDecoder().decode(CurrencyRateResponse.self, from: data)
                guard let rate = decoded.data[to]?.value else {
                    throw URLError(.cannotParseResponse)
                }

                return rate
            }
            .eraseToAnyPublisher()
    }
}
