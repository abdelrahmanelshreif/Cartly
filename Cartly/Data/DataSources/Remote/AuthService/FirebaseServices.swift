import FirebaseAuth

protocol FirebaseServiceProtocol{
    
    func signIn(email: String, password: String) async throws -> String?
    
    func signup(email: String, password: String) async throws -> String?
    
    func signOut() throws
    
    func getCurrentUser() -> String?
}

final class FirebaseServices: FirebaseServiceProtocol{
    
    func signIn(email: String, password: String) async throws -> String? {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.email
        }catch(let error){
            throw error
        }
    }
    
    func signup(email: String, password: String) async throws -> String? {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.email
        }catch(let error){
            throw error
        }
    }
    
    func signOut() throws {
        do{
            try Auth.auth().signOut()
        }catch(let error){
            throw error
        }
    }
    
    func getCurrentUser() -> String? {
        return Auth.auth().currentUser?.email
    }
}
