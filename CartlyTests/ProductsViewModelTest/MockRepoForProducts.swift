//
//  MockRepoForProducts.swift
//  CartlyTests
//
//  Created by Khaled Mustafa on 26/06/2025.
//

@testable import Cartly
import Combine
import Foundation

class MockRepository: RepositoryProtocol {
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchProducts(for collectionID: Int64) -> AnyPublisher<[ProductMapper], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchAllProducts() -> AnyPublisher<[ProductMapper], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<[WishlistProduct]?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func addWishlistProductForUser(whoseId id: String, withProduct product: WishlistProduct) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func removeWishlistProductForUser(whoseId id: String, withProduct productId: String) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func isProductInWishlist(withProduct productId: String, forUser id: String) -> AnyPublisher<Bool, Error> {
        return Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<DraftOrder?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func editDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func addToCart(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error> {
        return Just(.Added)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getAllDraftOrdersForCustomer() -> AnyPublisher<[CartMapper], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
