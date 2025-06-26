//
//  WishlistViewModelTest.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import Combine
import XCTest
@testable import Cartly

class WishlistViewModelTests: XCTestCase {

    var sut: WishlistViewModel!
    var mockGetWishlist: MockGetWishlistUseCase!
    var mockAddProduct: MockAddProductToWishlistUseCase!
    var mockRemoveProduct: MockRemoveProductFromWishlistUseCase!
    var mockSearchProduct: MockSearchProductAtWishlistUseCase!
    var mockGetCurrentUser: MockGetCurrentUserInfoUseCase!
    private var cancellables: Set<AnyCancellable>!

    let loggedInUser = UserEntity(
        id: "", email: "body@gmail.com", emailVerificationStatus: true,
        sessionStatus: true, name: "Abdelrahman")
    let loggedOutUser = UserEntity(
        id: nil, email: "body@gmail.com", emailVerificationStatus: true,
        sessionStatus: false, name: "Abdelrahman")
    let sampleProductInfo = ProductInformationEntity(
        id: 999, name: "Test Product", description: "Desc", vendor: "Vendor",
        images: [], price: 9.99, originalPrice: 9.99, availableSizes: [],
        availableColors: [], variants: [], rating: 4, reviewCount: 10)
    let sampleWishlistProduct = WishlistProduct(
        id: "fb_id_1", productId: "999", title: "Test Product", bodyHtml: "",
        vendor: "", productType: "", status: "", image: nil, price: 9.99)

    override func setUp() {
        super.setUp()
        cancellables = []
        mockGetWishlist = MockGetWishlistUseCase()
        mockAddProduct = MockAddProductToWishlistUseCase()
        mockRemoveProduct = MockRemoveProductFromWishlistUseCase()
        mockSearchProduct = MockSearchProductAtWishlistUseCase()
        mockGetCurrentUser = MockGetCurrentUserInfoUseCase()

        mockGetCurrentUser.userToReturn = loggedOutUser

        sut = WishlistViewModel(
            getWishlistUseCase: mockGetWishlist,
            addProductUseCase: mockAddProduct,
            removeProductUseCase: mockRemoveProduct,
            getProductDetailsUseCase: MockGetProductDetailsUseCase(),
            getCurrentUser: mockGetCurrentUser,
            searchProductAtWishlistUseCase: mockSearchProduct
        )
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        mockGetWishlist = nil
        mockAddProduct = nil
        mockRemoveProduct = nil
        mockSearchProduct = nil
        mockGetCurrentUser = nil
        super.tearDown()
    }

    func test_init_whenUserIsLoggedIn_isAuthorizedIsTrue() {
        mockGetCurrentUser.userToReturn = loggedInUser
        let localSut = WishlistViewModel(
            getWishlistUseCase: mockGetWishlist,
            addProductUseCase: mockAddProduct,
            removeProductUseCase: mockRemoveProduct,
            getProductDetailsUseCase: MockGetProductDetailsUseCase(),
            getCurrentUser: mockGetCurrentUser,
            searchProductAtWishlistUseCase: mockSearchProduct)
        XCTAssertTrue(localSut.isAuthorized)
    }

    func test_init_whenUserIsLoggedOut_isAuthorizedIsFalse() {
        XCTAssertFalse(sut.isAuthorized)
    }

    
    func test_addProduct_whenSuccessful_setsAtWishlistAndShowsAlert() {
        mockGetCurrentUser.userToReturn = loggedInUser
        let expectation = expectation(description: "addProduct success")

        sut.addProduct(product: sampleProductInfo)
        mockAddProduct.publisher.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertTrue(self.sut.atWishlist)
            XCTAssertTrue(self.sut.showWishlistAlert)
            XCTAssertEqual(self.sut.wishlistAlertMessage, "Product added to wishlist!")
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func test_anyMethod_whenUserIsLoggedOut_showsAlertOrSetsError() {
        sut.addProduct(product: sampleProductInfo)
        XCTAssertTrue(sut.showWishlistAlert)
        XCTAssertEqual(sut.wishlistAlertMessage, "Please login to add items to your wishlist")

        sut.removeProductAtWishlist(productId: "123")
        XCTAssertEqual(sut.wishlistAlertMessage, "Please login to manage your wishlist")

        sut.getUserWishlist()
        XCTAssertEqual(sut.error, "Please login to view your wishlist")
        XCTAssertFalse(sut.isLoading)
    }

    func test_removeProduct_whenSuccessful_removesFromLocalArrayAndShowsAlert() {
        mockGetCurrentUser.userToReturn = loggedInUser
        sut.userWishlist = [sampleWishlistProduct]
        let expectation = expectation(description: "removeProduct success")

        sut.removeProductAtWishlist(productId: "999")
        mockRemoveProduct.publisher.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertFalse(self.sut.atWishlist)
            XCTAssertTrue(self.sut.showWishlistAlert)
            XCTAssertEqual(self.sut.wishlistAlertMessage, "Product removed from wishlist.")
            XCTAssertTrue(self.sut.userWishlist.isEmpty)
           
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }


    func test_getUserWishlist_whenSuccessful_updatesUserWishlistAndStopsLoading() {
        mockGetCurrentUser.userToReturn = loggedInUser
        let expectation = expectation(description: "Wishlist updated")
        
        sut.getUserWishlist()

        mockGetWishlist.publisher.send([sampleWishlistProduct])
        mockGetWishlist.publisher.send(completion: .finished)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertEqual(self.sut.userWishlist.count, 1)
            XCTAssertEqual(self.sut.userWishlist.first?.productId, "999")
           
        }
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_toggleWishlist_whenProductIsInWishlist_callsRemove() {
        mockGetCurrentUser.userToReturn = loggedInUser
        sut.atWishlist = true

        sut.toggleWishlist(product: sampleProductInfo)

        XCTAssertTrue(mockRemoveProduct.executeWasCalled)
        XCTAssertFalse(mockAddProduct.executeWasCalled)
    }

    func test_toggleWishlist_whenProductIsNotInWishlist_callsAdd() {
        mockGetCurrentUser.userToReturn = loggedInUser
        sut.atWishlist = false

        sut.toggleWishlist(product: sampleProductInfo)

        XCTAssertTrue(mockAddProduct.executeWasCalled)
        XCTAssertFalse(mockRemoveProduct.executeWasCalled)
    }
}
