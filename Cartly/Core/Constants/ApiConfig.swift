import Foundation

/// Custom Method Enum Represents the HTTP methods available for API requests.
enum Method {
    case GET, POST, PUT, DELETE
}

struct BuissnessStrategies{
    static let sendEmails = true
}

/// Contains static configuration for Shopify API access.
struct APIConfig {
    static let APIVersion = "2024-07"

    static let StoreName = "mad45-ios2-sv"

    static let AccessToken = "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"
    

    /// https://{{store_name}}.myshopify.com/admin/api/{{api_version}}/smart_collections.json
    static var baseURL: String {
        return "https://\(StoreName).myshopify.com/admin/api/\(APIVersion)"
    }
}

/// Represents an API request to Shopify.
struct APIRequest {
    /// The HTTP method used for the request (e.g., GET, POST).
    let httpMethod: Method
    /// The endpoint path (e.g., "/products.json").
    let path: String
    /// HTTP headers to include with the request it is always same value for all requests.
    let header: [String: String]
    /// Optional parameters for the request (used in POST or PUT).
    let parameters: [String: Any]?
    /// Full URL composed of the base URL and path.
    var url: String {
        return APIConfig.baseURL + path
    }
    /**
         Initializes a new API request.

         - Parameters:
           - httpMethod: HTTP method to use (default is `.GET`).
           - path: API endpoint path.
           - parameters: Optional dictionary of request parameters.

         Example:
         ```
         let request = APIRequest(
             withMethod: .GET,
             withPath: "/custom_collections.json"
         )
         ```
         */
    init(
        withMethod httpMethod: Method = .GET,
        withPath path: String,
        withParameters parameters: [String: Any]? = nil) {
        self.httpMethod = httpMethod
        self.path = path
        self.parameters = parameters
        header = [
            "X-Shopify-Access-Token": APIConfig.AccessToken,
            "Content-Type": "application/json",
        ]
    }
}
