//
//  FirebaseDataSourceTests.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 14/6/25.
//

import XCTest
import Combine
@testable import Cartly

final class FirebaseDataSourceTests: XCTestCase {

    var dataSource: FirebaseDataSource!
    var mockFirebaseService: MockFirebaseServices!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockFirebaseService = MockFirebaseServices()
        dataSource = FirebaseDataSource(firebaseServices: mockFirebaseService)
        cancellables = []
    }

    override func tearDown() {
        dataSource = nil
        mockFirebaseService = nil
        cancellables = nil
        super.tearDown()
    }

    func testGetWishlistProductsForUser_whenServiceSucceeds_forwardsProducts() {
        // Arrange
        let expectation = XCTestExpectation(description: "Successfully fetches wishlist products")
        let mockProducts = [WishlistProduct(id: "user1", productId: "4", title: "perfume", bodyHtml: "desc", vendor: "adidas", productType: "perfume", status: "available", image: "url", price: 15.99)]
        var receivedProducts: [WishlistProduct]?
        
        // Act
        dataSource.getWishlistProductsForUser(whoseId: "user1")
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { products in receivedProducts = products })
            .store(in: &cancellables)
            
        // Control: Tell the mock service to send the success value.
        mockFirebaseService.getUserWishlistSubject.send(mockProducts)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockFirebaseService.getUserWishlistCallCount, 1, "getUserWishlist should be called once.")
        XCTAssertEqual(receivedProducts, mockProducts, "The received products should match the mocked products.")
    }

    // Test a failure case where the service returns an error
    func testAddWishlistProduct_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fails to add a product")
        let productToAdd = WishlistProduct(id: "user1", productId: "4", title: "perfume", bodyHtml: "desc", vendor: "adidas", productType: "perfume", status: "available", image: "url", price: 15.99)
        let expectedError = MockError.generic
        var receivedError: Error?
        
        // Act
        dataSource.addWishlistProductForUser(whoseId: "user2", withProduct: productToAdd)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // Control: Tell the mock service to send a failure.
        mockFirebaseService.addProductToWishlistSubject.send(completion: .failure(expectedError))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.addProductToWishlistCallCount, 1)
        
        // Spy: Check that the correct arguments were passed to the service.
        XCTAssertEqual(mockFirebaseService.lastUserIdForAdd, "user2")
        XCTAssertEqual(mockFirebaseService.lastAddedWishlistProduct, productToAdd)
        
        // Assert the error was received
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is MockError, "The error should be the one we sent from the mock.")
    }
}
