
import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    ///https://{apikey}:{password}@{hostname}/admin/api/{version}/{resource}.json
    static  let baseURL = "https://75497c7d6393ab0bc059533f558aeb79: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@mad45-ios2-sv.myshopify.com/admin/api/2024-07/custom_collections.json"
    private init() {}
    
    func getProducts(completion: @escaping (Result<[CustomCollection], APError>) -> Void){
        guard let url = URL(string: NetworkManager.baseURL) else {
            return completion(.failure(.invalidURL))
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let _ = error  {
                print("Error before fetching data")
                return completion(.failure(APError.unableToCompelete))
            }
            
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                return completion(.failure(APError.invalidResponse))
//            }
            
            guard let data = data else {
               return completion(.failure(APError.invalidData))
            }
            
            do{
                let finalProductResponse = try JSONDecoder().decode(CustomCollectionsResponse.self, from: data)
                print("Data is fetched successfully \(finalProductResponse.customCollections)")
                completion(.success(finalProductResponse.customCollections ?? []))
            }catch {
                print("Error in fetch data")
                completion(.failure(APError.invalidData))
            }
        }
        
        task.resume()
    }
}
