import Alamofire
import Combine

/// A protocol that defines a generic networking service using Combine.
/// Any conforming type must implement a method to perform a request and decode the response.
protocol NetworkServiceProtocol {
    /// Sends a request and decodes the response into a given Codable type.
       ///
       /// - Parameters:
       ///   - request: An `APIRequest` containing endpoint info, method, headers, and parameters.
       ///   - responseType: The expected response type conforming to `Codable`.
       /// - Returns: A Combine `AnyPublisher` that emits the decoded response or an error.
    func request<T: Codable>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T, Error>
}

/// A concrete implementation of `NetworkServiceProtocol` using Alamofire.
/// Sends network requests and decodes responses using Combine publishers.
final class AlamofireService: NetworkServiceProtocol {
    
     /// Performs a network request using Alamofire and returns a Combine publisher.
     ///
     /// - Parameters:
     ///   - request: An `APIRequest` object that holds the URL, HTTP method, parameters, and headers.
     ///   - responseType: The type to decode the response into. Must conform to `Decodable` and `Encodable`.
     /// - Returns: An `AnyPublisher<T, Error>` that publishes a decoded object of type `T` or an error.
    func request<T>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T, any Error> where T: Decodable, T: Encodable {
        return AF.request(request.url,
                     method: HTTPMethod(rawValue: request.httpMethod),
                     parameters: request.parameters,
                     encoding: JSONEncoding.default,
                     headers: HTTPHeaders(request.header))
            .validate() /// Validates response status code and return DataRequest Object coming from AF.request func.
            .publishData() /// Publishes the response ( DataRequest Object ) as DataResponsePublisher<Data>.
            .tryMap {
                /// Try to extract and decode the data from the response
                guard let data = $0.data else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(T.self, from: data)
            }
            .eraseToAnyPublisher() /// wrapping this publisher to AnyPublisher<Output,Failure>
    }
}
