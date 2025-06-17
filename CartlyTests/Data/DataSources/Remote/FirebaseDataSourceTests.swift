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

    // MARK: - Get Wishlist Products Tests
    
    func testGetWishlistProductsForUser_whenServiceSucceeds_forwardsProducts() {
        // Arrange
        let expectation = XCTestExpectation(description: "Successfully fetches wishlist products")
        let mockProducts = [
            WishlistProduct(id: "user1", productId: "4", title: "perfume", bodyHtml: "desc", vendor: "adidas", productType: "perfume", status: "available", image: "url", price: 15.99),
            WishlistProduct(id: "user1", productId: "5", title: "shoes", bodyHtml: "desc2", vendor: "nike", productType: "footwear", status: "available", image: "url2", price: 89.99)
        ]
        var receivedProducts: [WishlistProduct]?
        var completionReceived = false
        
        // Act
        dataSource.getWishlistProductsForUser(whoseId: "user1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { products in
                    receivedProducts = products
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.getUserWishlistSubject.send(mockProducts)
        mockFirebaseService.getUserWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.getUserWishlistCallCount, 1, "getUserWishlist should be called once")
        XCTAssertNotNil(receivedProducts, "Products should not be nil")
        XCTAssertEqual(receivedProducts?.count, 2)
        XCTAssertEqual(receivedProducts, mockProducts, "The received products should match the mocked products")
    }
    
    func testGetWishlistProductsForUser_whenServiceReturnsNil_forwardsNil() {
        // Arrange
        let expectation = XCTestExpectation(description: "Successfully handles nil wishlist")
        var receivedProducts: [WishlistProduct]? = []  // Initialize with non-nil to ensure it's set to nil
        var completionReceived = false
        
        // Act
        dataSource.getWishlistProductsForUser(whoseId: "user1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { products in
                    receivedProducts = products
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.getUserWishlistSubject.send(nil)
        mockFirebaseService.getUserWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.getUserWishlistCallCount, 1)
        XCTAssertNil(receivedProducts, "Products should be nil")
    }
    
    func testGetWishlistProductsForUser_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Handles error from service")
        let expectedError = MockError.generic
        var receivedError: Error?
        
        // Act
        dataSource.getWishlistProductsForUser(whoseId: "user1")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.getUserWishlistSubject.send(completion: .failure(expectedError))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.getUserWishlistCallCount, 1)
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is MockError)
    }

    // MARK: - Add Wishlist Product Tests
    
    func testAddWishlistProductForUser_whenServiceSucceeds_completesSuccessfully() {
        // Arrange
        let expectation = XCTestExpectation(description: "Successfully adds product")
        let productToAdd = WishlistProduct(id: "user1", productId: "4", title: "perfume", bodyHtml: "desc", vendor: "adidas", productType: "perfume", status: "available", image: "url", price: 15.99)
        var completionReceived = false
        
        // Act
        dataSource.addWishlistProductForUser(whoseId: "user1", withProduct: productToAdd)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.addProductToWishlistSubject.send(())
        mockFirebaseService.addProductToWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.addProductToWishlistCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastUserIdForAdd, "user1")
        XCTAssertEqual(mockFirebaseService.lastAddedWishlistProduct, productToAdd)
    }

    func testAddWishlistProductForUser_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fails to add product")
        let productToAdd = WishlistProduct(id: "user2", productId: "4", title: "perfume", bodyHtml: "desc", vendor: "adidas", productType: "perfume", status: "available", image: "url", price: 15.99)
        let expectedError = MockError.generic
        var receivedError: Error?
        
        // Act
        dataSource.addWishlistProductForUser(whoseId: "user2", withProduct: productToAdd)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.addProductToWishlistSubject.send(completion: .failure(expectedError))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.addProductToWishlistCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastUserIdForAdd, "user2")
        XCTAssertEqual(mockFirebaseService.lastAddedWishlistProduct, productToAdd)
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is MockError)
    }

    // MARK: - Remove Wishlist Product Tests
    
    func testRemoveWishlistProductForUser_whenServiceSucceeds_completesSuccessfully() {
        // Arrange
        let expectation = XCTestExpectation(description: "Successfully removes product")
        var completionReceived = false
        
        // Act
        dataSource.removeWishlistProductForUser(whoseId: "user1", withProduct: "product123")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.removeProductFromWishlistSubject.send(())
        mockFirebaseService.removeProductFromWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.removeProductFromWishlistCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastRemovedProductId, "product123")
    }

    func testRemoveWishlistProductForUser_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fails to remove product")
        let expectedError = MockError.generic
        var receivedError: Error?
        
        // Act
        dataSource.removeWishlistProductForUser(whoseId: "user1", withProduct: "product123")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.removeProductFromWishlistSubject.send(completion: .failure(expectedError))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.removeProductFromWishlistCallCount, 1)
        XCTAssertEqual(mockFirebaseService.lastRemovedProductId, "product123")
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is MockError)
    }

    // MARK: - Is Product in Wishlist Tests
    
    func testIsProductInWishlist_whenProductExists_returnsTrue() {
        // Arrange
        let expectation = XCTestExpectation(description: "Product exists in wishlist")
        var receivedResult: Bool?
        var completionReceived = false
        
        // Act
        dataSource.isProductInWishlist(withProduct: "product123", forUser: "user1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { isInWishlist in
                    receivedResult = isInWishlist
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.isProductInWishlistSubject.send(true)
        mockFirebaseService.isProductInWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.isProductInWishlistCallCount, 1)
        XCTAssertEqual(receivedResult, true)
    }

    func testIsProductInWishlist_whenProductDoesNotExist_returnsFalse() {
        // Arrange
        let expectation = XCTestExpectation(description: "Product not in wishlist")
        var receivedResult: Bool?
        var completionReceived = false
        
        // Act
        dataSource.isProductInWishlist(withProduct: "product123", forUser: "user1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionReceived = true
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { isInWishlist in
                    receivedResult = isInWishlist
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.isProductInWishlistSubject.send(false)
        mockFirebaseService.isProductInWishlistSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionReceived, "Completion should be received")
        XCTAssertEqual(mockFirebaseService.isProductInWishlistCallCount, 1)
        XCTAssertEqual(receivedResult, false)
    }

    func testIsProductInWishlist_whenServiceFails_forwardsError() {
        // Arrange
        let expectation = XCTestExpectation(description: "Service fails to check wishlist")
        let expectedError = MockError.generic
        var receivedError: Error?
        
        // Act
        dataSource.isProductInWishlist(withProduct: "product123", forUser: "user1")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockFirebaseService.isProductInWishlistSubject.send(completion: .failure(expectedError))
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockFirebaseService.isProductInWishlistCallCount, 1)
        XCTAssertNotNil(receivedError)
        XCTAssert(receivedError is MockError)
    }
}
