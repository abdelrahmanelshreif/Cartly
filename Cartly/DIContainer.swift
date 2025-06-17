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
    
    func resolveAddressViewModel() -> AddressesViewModel{
        return AddressesViewModel(fetchAddressesUseCase: resolveFetchCustomerAddressUseCase(), addAddressUseCase: resolveAddCustomerAddressUseCase(), setDefaultAddressUseCase: resolveSetDefaultAddressUseCase(), deleteAddressUseCase: resolveDeleteCustomerAddressUseCase(), editAddressUseCase: resolveEditCustomerAddressUseCase())
    }
    
    private func resolveFetchCustomerAddressUseCase() -> FetchCustomerAddressesUseCaseProtocol{
        return FetchCustomerAddressesUseCase(repository: resolveAddressRepository() )
    }
    
    private func resolveAddressRepository() -> CustomerAddressRepositoryProtocol{
        return CustomerAddressRepository(networkService: resolveAFNetworking())
    }
    
    private func resolveAddCustomerAddressUseCase() -> AddCustomerAddressUseCaseProtocol{
        return AddCustomerAddressUseCase(repository: resolveAddressRepository())
    }
    
    private func resolveSetDefaultAddressUseCase() -> SetDefaultCustomerAddressUseCaseProtocol{
        return SetDefaultCustomerAddressUseCase(repository: resolveAddressRepository())
    }
    
    private func resolveDeleteCustomerAddressUseCase() -> DeleteCustomerAddressUseCaseProtocol{
        return DeleteCustomerAddressUseCase(repository: resolveAddressRepository())
    }
    
    private func resolveEditCustomerAddressUseCase() -> EditCustomerAddressUseCaseProtocol{
        return EditCustomerAddressUseCase(repository: resolveAddressRepository())
    }
    func resolveSignUpViewModel() -> SignUpViewModel{
        return SignUpViewModel(createAccountUseCase: resolveCreateAccounttUseCase(), googleSignInUseCase: resolveGoogleSignInUseCase(),validator: resolveSignUpValidators())
    }
    
    func resolveSettingsViewModel() -> SettingsViewModel{
        return SettingsViewModel(useCase: resolveConvertCurrencyUseCase())
    }
    
    
    func resolveProfileViewModel() -> ProfileViewModel{
        return ProfileViewModel(signOutUseCase: resolveSignOutUseCase(), getUserSession: resolveGettingCurrentInfo(), getOrdersUseCase: resolveGetOrdersUseCase())
    }
    func resolveProductDetailsViewModel() -> ProductDetailsViewModel{
        return ProductDetailsViewModel(getProductUseCase: resolveGetProductUseCase())
    }
    
    func resolveLoginViewModel() -> LoginViewModel{
        return LoginViewModel(loginUseCase: resolveLoginUseCase() as! FirebaseShopifyLoginUseCase, validator: resolveValidators() as! LoginValidator, loginUsingGoogleUseCase: resolveGoogleSignInUseCase())
    }
    
    func resolveWishlistViewModel() -> WishlistViewModel{
        return WishlistViewModel(getWishlistUseCase: resolveGetWishlistUsecase(), addProductUseCase: resolveAddProductToWishlistUseCase(), removeProductUseCase: resolveRemoveProductFromWishlistUseCase(), getProductDetailsUseCase: resolveGetProductUseCase(), getCurrentUser: resolveGettingCurrentInfo() , searchProductAtWishlistUseCase: resolveSearcingInWishlistUseCase())
    }
    
    private func resolveConvertCurrencyUseCase() -> ConvertCurrencyUseCaseProtocol{
        return ConvertCurrencyUseCase(repository: resolveCurrencyRepository())
    }
    
    private func resolveGetOrdersUseCase() -> GetCustomerOrderUseCaseProtocol{
        return GetCustomerOrdersUseCase(repository: resolveShopifyRepository())
    }
    
    private func resolveCurrencyRepository() -> CurrencyRepositoryProtocol{
        return CurrencyRepository(service: resolveCurrencyAPIService())
    }
    
    private func resolveCurrencyAPIService() -> CurrencyAPIServiceProtocol{
        return CurrencyAPIService()
    }
    private func resolveGoogleSignInUseCase() -> AuthenticatingUserWithGoogleUseCaseProtocol{
        return AuthenticatingUserWithGoogleUseCase(authRepository: resolveAuthenticationRepository(), shopifyRepo: resolveShopifyRepository(), userSessionService: resolveUserSessionService())
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

