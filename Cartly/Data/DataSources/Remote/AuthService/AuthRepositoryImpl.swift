import Foundation

class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    typealias CredentialsType = EmailCredentials
    typealias SignUpDataType = SignUpData
    typealias UserType = Customer
    
    let firebaseAuthClient: FirebaseServiceProtocol
    let shopifyAuthClient: any ShopifyServicesProtocol
    
    static let shared = AuthRepositoryImpl()
    
    private init(){
        firebaseAuthClient = FirebaseServices()
        shopifyAuthClient = ShopifyServices()
    }
    
    func signup(signUpData: SignUpData) async throws -> Customer {
            
    }
    
    func signIn(credentials: EmailCredentials) async throws -> Customer {
    }
    
    func signOut() throws {
        
    }
    
    func getCurrentUser() -> Customer? {
        // we will return customer
    }
    
    func isUserVerified() -> Bool {
        return false
    }
    
    func isUserLoggedIn() -> Bool {
        return false
    }

}
