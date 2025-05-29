import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    static let baseURL = "https://75497c7d6393ab0bc059533f558aeb79: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@mad45-ios2-sv.myshopify.com/admin/api/2024-07/custom_collections.json"
    
    /// Use an ephemeral session to avoid persistent cookies/cache (fixes timeout on simulator)
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    func getProducts(completion: @escaping (Result<[CustomCollection], APError>) -> Void) {
        guard let url = URL(string: NetworkManager.baseURL) else {
            return completion(.failure(.invalidURL))
        }

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error during request: \(error.localizedDescription)")
                return completion(.failure(.unableToCompelete))
            }

            guard let data = data else {
                print("❌ No data received")
                return completion(.failure(.invalidData))
            }

            do {
                let finalProductResponse = try JSONDecoder().decode(CustomCollectionsResponse.self, from: data)
                print("✅ Data fetched: \(finalProductResponse.customCollections ?? [])")
                completion(.success(finalProductResponse.customCollections ?? []))
            } catch {
                print("❌ JSON Decoding error: \(error)")
                completion(.failure(.invalidData))
            }
        }

        task.resume()
    }
}
