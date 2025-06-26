//
//  ProductDetailsTests.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/6/25.
//

import Combine
import XCTest

@testable import Cartly

struct MockProductData {
    static var productEntity: ProductInformationEntity {
        let variant1 = ProductInformationVariantEntity(
            id: 101, title: "S / Red", price: 19.99, size: "S", color: "Red",
            inventoryQuantity: 10, isAvailable: true)
        let variant2 = ProductInformationVariantEntity(
            id: 102, title: "M / Red", price: 19.99, size: "M", color: "Red",
            inventoryQuantity: 5, isAvailable: true)
        let variant3 = ProductInformationVariantEntity(
            id: 103, title: "S / Blue", price: 21.99, size: "S", color: "Blue",
            inventoryQuantity: 0, isAvailable: false)

        return ProductInformationEntity(
            id: 1,
            name: "Test T-Shirt",
            description: "A nice t-shirt",
            vendor: "Mock Vendor",
            images: [],
            price: 19.99,
            originalPrice: 25.00,
            availableSizes: ["S", "M"],
            availableColors: ["Red", "Blue"],
            variants: [variant1, variant2, variant3],
            rating: 4.5,
            reviewCount: 100
        )
    }
}

struct ProducInformationtMapper {
    static var productToReturn: ProductInformationEntity = MockProductData
        .productEntity

    static func mapShopifyProductToProductView(_ product: Product)
        -> ProductInformationEntity
    {
        return productToReturn
    }
}

class ProductDetailsViewModelTests: XCTestCase {

    var sut: ProductDetailsViewModel!
    var mockGetProductUseCase: MockGetProductDetailsUseCase!
    var mockAddToCartUseCase: MockAddToCartUseCase!
    var mockUserSession: UserSessionServiceProtocol!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockGetProductUseCase = MockGetProductDetailsUseCase()
        mockAddToCartUseCase = MockAddToCartUseCase()
        mockUserSession = MockUserSessionService()

        ProducInformationtMapper.productToReturn = MockProductData.productEntity

        sut = ProductDetailsViewModel(
            getProductUseCase: mockGetProductUseCase,
            addToCartUseCase: mockAddToCartUseCase,
            userSession: mockUserSession
        )
    }

    override func tearDown() {
        sut = nil
        mockGetProductUseCase = nil
        mockAddToCartUseCase = nil
        mockUserSession = nil
        cancellables = nil
        super.tearDown()
    }

    func test_getProduct_whenSuccessful_updatesResultStateToSuccess() {
        let expectation = XCTestExpectation(
            description: "State should be updated to success")

        sut.$resultState.dropFirst().sink { state in
            if case .success(let receivedProduct) = state {
                XCTAssertEqual(
                    receivedProduct.id, MockProductData.productEntity.id)
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.getProduct(for: 1)
        mockGetProductUseCase.publisher.send(
            .success(Product(id: 1, title: "Test")))

        wait(for: [expectation], timeout: 1.0)
    }


    func test_getProduct_whenSourceIsCart_selectsSpecifiedVariant() {
        let targetVariantId: Int64 = 102
        let expectation = XCTestExpectation(
            description: "Should select the variant specified from cart")

        sut.$selectedVariant.dropFirst().sink { variant in
            if let variant = variant {
                XCTAssertEqual(variant.id, targetVariantId)
                XCTAssertEqual(self.sut.selectedSize, "M")
                XCTAssertEqual(self.sut.selectedColor, "Red")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.getProduct(
            for: 1, sourceisCart: true, cartVarientId: targetVariantId)
        mockGetProductUseCase.publisher.send(
            .success(Product(id: 1, title: "Test")))

        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_updateSelectedVariant_whenValidSelection_enablesAddToCart() {
        sut.currentProduct = MockProductData.productEntity
        sut.selectedSize = "M"
        sut.selectedColor = "Red"
        XCTAssertNotNil(sut.selectedVariant)
        XCTAssertEqual(sut.selectedVariant?.id, 102)
        XCTAssertTrue(sut.isAddToCartEnabled)
    }

    func
        test_updateSelectedVariant_whenSelectionIsUnavailable_disablesAddToCart()
    {
        sut.currentProduct = MockProductData.productEntity
        sut.selectedSize = "S"
        sut.selectedColor = "Blue"
        XCTAssertNotNil(sut.selectedVariant)
        XCTAssertFalse(sut.isAddToCartEnabled)
    }

    func test_incrementQuantity_whenAtStockLimit_doesNotIncreaseQuantity() {
        sut.currentProduct = MockProductData.productEntity
        sut.selectedSize = "S"
        sut.selectedColor = "Red"
        sut.quantity = 10
        sut.incrementQuantity()
        XCTAssertEqual(sut.quantity, 10)
    }

    // MARK: - Add To Cart Tests

    private func setupForAddToCartTests() {
        sut.currentProduct = MockProductData.productEntity
        sut.selectedSize = "M"
        sut.selectedColor = "Red"
    }

    func test_addToCart_whenUserNotLoggedIn_triggersAlertAndDoesNotCallUseCase()
    {
        setupForAddToCartTests()
        sut.addToCart()
        XCTAssertTrue(sut.triggerAlert)
        XCTAssertEqual(sut.alertMessage, "Please login to add items to cart")
        XCTAssertFalse(mockAddToCartUseCase.executeWasCalled)
    }

    func test_addToCart_whenQuantityExceedsStock_triggersAlert() {
        setupForAddToCartTests()
        sut.quantity = 6
        sut.addToCart()
        XCTAssertTrue(sut.triggerAlert)
        XCTAssertEqual(
            sut.alertMessage, "Requested quantity exceeds available stock")
        XCTAssertFalse(mockAddToCartUseCase.executeWasCalled)
    }

    func test_addToCart_whenQuantityExceedsMaxCartLimit_triggersAlert() {
        setupForAddToCartTests()
        sut.quantity = 6
        sut.addToCart()
        XCTAssertTrue(sut.triggerAlert)
        XCTAssertFalse(mockAddToCartUseCase.executeWasCalled)
    }

    func test_computedProperties_reflectSelectedVariantState() {
        sut.currentProduct = MockProductData.productEntity

        XCTAssertEqual(sut.availableStock, 0)
        XCTAssertFalse(sut.isVariantAvailable)

        sut.selectedSize = "S"
        sut.selectedColor = "Red"
        XCTAssertEqual(sut.availableStock, 10)
        XCTAssertTrue(sut.isVariantAvailable)
        XCTAssertEqual(sut.variantPrice, 19.99)
        sut.selectedSize = "S"
        sut.selectedColor = "Blue"
        XCTAssertEqual(sut.availableStock, 0)
        XCTAssertFalse(sut.isVariantAvailable)

    }

}
