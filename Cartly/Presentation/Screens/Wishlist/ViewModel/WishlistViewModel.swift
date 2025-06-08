//
//  WishlistViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//
import Foundation
import Combine

class WishlistViewModel: ObservableObject {
    @Published var showWishlistAlert = false
    @Published var wishlistAlertMessage = ""
    @Published var atWishlist = false
    @Published var userWishlist:[WishlistProduct] = []
    @Published var isLoading = true
    @Published var error = ""
    @Published var isAuthorized = false
    
    private let getWishlistUseCase: GetWishlistUseCaseProtocol
    private let addProductUseCase: AddProductToWishlistUseCaseProtocol
    private let removeProductUseCase: RemoveProductFromWishlistUseCaseProtocol
    private let getProductDetailsUseCase: GetProductDetailsUseCaseProtocol
    private let getCurrentUser: GetCurrentUserInfoUseCaseProtocol
    private let searchProductAtWishlistUseCase: SearchProductAtWishlistUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(getWishlistUseCase: GetWishlistUseCaseProtocol,
         addProductUseCase: AddProductToWishlistUseCaseProtocol,
         removeProductUseCase: RemoveProductFromWishlistUseCaseProtocol,
         getProductDetailsUseCase: GetProductDetailsUseCaseProtocol,
         getCurrentUser: GetCurrentUserInfoUseCaseProtocol,
         searchProductAtWishlistUseCase: SearchProductAtWishlistUseCaseProtocol) {
        self.getWishlistUseCase = getWishlistUseCase
        self.addProductUseCase = addProductUseCase
        self.removeProductUseCase = removeProductUseCase
        self.getProductDetailsUseCase = getProductDetailsUseCase
        self.getCurrentUser = getCurrentUser
        self.searchProductAtWishlistUseCase = searchProductAtWishlistUseCase
    }
    
    private func isUserAuthorized() -> Bool {
        let user = getCurrentUser.execute()
        return user.id != nil && user.sessionStatus
    }
    
    func addProduct(product: ProductInformationEntity) {
        guard isUserAuthorized() else {
            wishlistAlertMessage = "Please login to add items to your wishlist"
            showWishlistAlert = true
            return
        }

        let wishlistProduct = WishlistProduct.from(entity: product)
        
        addProductUseCase.execute(userId: getCurrentUser.execute().id!, product: wishlistProduct)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.wishlistAlertMessage = "Failed to add product: \(error.localizedDescription)"
                        self?.showWishlistAlert = true
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self = self else { return }
                    print("Product added - receiveValue called")
                    self.atWishlist = true
                    self.wishlistAlertMessage = "Product added to wishlist!"
                    self.showWishlistAlert = true
                }
            )
            .store(in: &cancellables)
    }
    
    func searchProductAtWishlist(productId: String) {
        guard isUserAuthorized() else {
            atWishlist = false
            return
        }
        
        searchProductAtWishlistUseCase.execute(userId: getCurrentUser.execute().id!, productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        print("Failed to search wishlist")
                    }
                },
                receiveValue: { [weak self] productStatusAtWishlist in
                    self?.atWishlist = productStatusAtWishlist
                    print("Product search result: \(productStatusAtWishlist)")
                }
            )
            .store(in: &cancellables)
    }
    
    func removeProductAtWishlist(productId: String) {
        guard isUserAuthorized() else {
            wishlistAlertMessage = "Please login to manage your wishlist"
            showWishlistAlert = true
            return
        }

        removeProductUseCase.execute(userId: getCurrentUser.execute().id!, productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] status in
                    guard let self = self else { return }
                    switch status {
                    case .finished:
                        print("Remove product - Completion finished")
                    case .failure(let error):
                        self.wishlistAlertMessage = "Failed to remove product: \(error.localizedDescription)"
                        self.showWishlistAlert = true
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.atWishlist = false
                    self.wishlistAlertMessage = "Product removed from wishlist."
                    self.showWishlistAlert = true
                }
            )
            .store(in: &cancellables)
    }
    
    func getUserWishlist(){
        guard isUserAuthorized() else {
            userWishlist = []
            isLoading = false
            error = "Please login to view your wishlist"
            return
        }
        
        userWishlist = []
        isLoading = true
        getWishlistUseCase.execute(userId: getCurrentUser.execute().id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Fetching Wishlist has been Done")
                case .failure(let error):
                    print("Fetching Wishlist Failed \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] result in
                guard let wishlistProducts = result else{
                    self?.isLoading = false
                    self?.error = "Failed to fetch you wishlist please try again later..."
                    return
                }
                self?.userWishlist = wishlistProducts
                self?.isLoading = false
            }).store(in: &cancellables)
    }
    
    func toggleWishlist(product: ProductInformationEntity) {
        guard isUserAuthorized() else {
            wishlistAlertMessage = "Please login to manage your wishlist"
            showWishlistAlert = true
            return
        }
        
        if atWishlist {
            removeProductAtWishlist(productId: String(product.id))
        } else {
            addProduct(product: product)
        }
    }
    
    func checkAuthorization(){
        self.isAuthorized = getCurrentUser.execute().sessionStatus
    }
}
