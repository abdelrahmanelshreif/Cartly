
protocol ShopifyServicesProtocol{
    
    associatedtype SignUpDataType : Codable
    
    associatedtype UserType : Codable

    func signup(userData : SignUpDataType) async throws -> UserType?
    
    func getCurrentUser() -> UserType?
}

final class ShopifyServices: ShopifyServicesProtocol{
    
    typealias SignUpDataType = SignUpData
    
    typealias UserType = Customer
    
    func signup(userData: SignUpData) async throws -> Customer? {
        /// 1- Shopify Post request with alamofire
        /// 2- if step 1 success then store Customer_ID in keyChain
        /// 3- login with firebase -> firebaseAuthClient.signIn(email, password).
        ///
        return nil 
    }
    
    func getCurrentUser() -> Customer? {
        return nil
    }
}
