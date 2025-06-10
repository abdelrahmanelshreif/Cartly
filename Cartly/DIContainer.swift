//
//  DIContainer.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

import Foundation

class DIContainer{

    static let shared = DIContainer()
    private init() {}
    
    func resolveSignUpViewModel() -> SignUpViewModel{
        return SignUpViewModel(createAccountUseCase: resolveCreateAccounttUseCase(), validator: resolveSignUpValidators())
    }
    
    func resolveProfileViewModel() -> ProfileViewModel{
        return ProfileViewModel(signOutUseCase: resolveSignOutUseCase(), getUserSession: resolveGettingCurrentInfo())
    }
    func resolveProductDetailsViewModel() -> ProductDetailsViewModel{
        return ProductDetailsViewModel(getProductUseCase: resolveGetProductUseCase())
    }
    
    func resolveLoginViewModel() -> LoginViewModel{
        return LoginViewModel(loginUseCase: resolveLoginUseCase() as! FirebaseShopifyLoginUseCase, validator: resolveValidators() as! LoginValidator)
    }
    
    func resolveWishlistViewModel() -> WishlistViewModel{
        return WishlistViewModel(getWishlistUseCase: resolveGetWishlistUsecase(), addProductUseCase: resolveAddProductToWishlistUseCase(), removeProductUseCase: resolveRemoveProductFromWishlistUseCase(), getProductDetailsUseCase: resolveGetProductUseCase(), getCurrentUser: resolveGettingCurrentInfo() , searchProductAtWishlistUseCase: resolveSearcingInWishlistUseCase())
    }
    private func resolveSignUpValidators() -> SignUpValidatorProtocol{
        return SignUpValidator()
    }
    private func resolveSearcingInWishlistUseCase() -> SearchProductAtWishlistUseCaseProtocol{
        return SearchProductAtWishlistUseCase(repository: resolveShopifyRepository())
    }
    
    private func resolveCreateAccounttUseCase() -> CreateAccountUseCaseProtocol{
        return CreateAccountUseCase(authRepository: resolveAuthenticationRepository(), userSessionService: resolveUserSessionService())
    }
    private func resolveSignOutUseCase() -> SignOutUseCaseProtocol{
        return SignOutUseCase()
    }
  
    private func resolveLoginUseCase() -> FirebaseShopifyLoginUseCaseProtocol{
        return FirebaseShopifyLoginUseCase(authRepository: resolveAuthenticationRepository(), customerRepository: resolveShopifyRepository(), userSessionService: resolveUserSessionService())
    }
    private func resolveValidators() -> LoginValidatorProtocol{
        return LoginValidator()
    }
    private func resolveUserSessionService() -> UserSessionServiceProtocol{
        return UserSessionService()
    }
    private func resolveGettingCurrentInfo() -> GetCurrentUserInfoUseCaseProtocol{
        return GetCurrentUserInfoUseCase(authenticationRepo: resolveAuthenticationRepository())
    }
    private func resolveAuthenticationRepository() -> AuthRepositoryProtocol {
        return AuthRepositoryImpl.shared
    }
    private func resolveGetWishlistUsecase() -> GetWishlistUseCaseProtocol{
        return GetUserWishlistUseCase(repository: resolveShopifyRepository())
    }
    
    private func resolveAddProductToWishlistUseCase() -> AddProductToWishlistUseCaseProtocol{
        return AddProductToWishlistUseCase(repository: resolveShopifyRepository())
    }
    
    private func resolveRemoveProductFromWishlistUseCase() -> RemoveProductFromWishlistUseCaseProtocol{
        return RemoveProductFromWishlistUseCase(repository: resolveShopifyRepository())
    }
    private func resolveGetProductUseCase() -> GetProductDetailsUseCaseProtocol {
        return GetProductDetailsUseCase(repository: resolveShopifyRepository())
    }

    private func resolveShopifyRepository() -> RepositoryProtocol {
        return RepositoryImpl(remoteDataSource: resolveRemoteDataSource(), firebaseRemoteDataSource: resolveFirebaseRemoteDataSource())
    }
    
    private func resolveRemoteDataSource() -> RemoteDataSourceProtocol {
        return RemoteDataSourceImpl(networkService: resolveAFNetworking())
    }
    
    private func resolveAFNetworking() -> NetworkServiceProtocol{
        return AlamofireService()
    }
  
    private func resolveFirebaseRemoteDataSource() -> FirebaseDataSourceProtocol{
        return FirebaseDataSource(firebaseServices: resolveFirebaseServices())
    }
    private func resolveFirebaseServices() -> FirebaseServiceProtocol {
        return FirebaseServices()
    }
}

