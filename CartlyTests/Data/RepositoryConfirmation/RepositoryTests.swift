//
//  RepositoryImplTests.swift
//  CartlyTests
//
//

import Combine
import XCTest

@testable import Cartly

// MARK: - Error Type Enum
enum ErrorType: Error {
    case noData
    case failUnWrapself
}

final class RepositoryImplTests: XCTestCase {

    var sut: RepositoryImpl!
    var mockRemoteDataSource: MockRemoteDataSource!
    var mockFirebaseDataSource: MockFirebaseDataSource!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockRemoteDataSource()
        mockFirebaseDataSource = MockFirebaseDataSource()
        sut = RepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            firebaseRemoteDataSource: mockFirebaseDataSource
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        mockRemoteDataSource = nil
        mockFirebaseDataSource = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Fetch Brands Tests

    func testFetchBrands_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch brands success")
        let smartCollections = [
            SmartCollection(id: 1, handle: "nike", title: "Nike"),
            SmartCollection(id: 2, handle: "adidas", title: "Adidas"),
        ]
        let expectedResponse = SmartCollectionsResponse(
            smartCollections: smartCollections)

        // When
        sut.fetchBrands()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { brands in
                    XCTAssertEqual(brands.count, 2)
                    XCTAssertEqual(brands[0].brand_title, "Nike")
                    XCTAssertEqual(brands[1].brand_title, "Adidas")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.fetchBrandsSubject.send(expectedResponse)
        mockRemoteDataSource.fetchBrandsSubject.send(completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.fetchBrandsCallCount, 1)
    }

    // MARK: - Fetch Products Tests

    func testFetchProductsForCollection_Success() {
        // Given
        let collectionId: Int64 = 12345
        let expectation = XCTestExpectation(
            description: "Fetch products success")
        let products = [
            createMockProduct(id: 1, title: "Product 1"),
            createMockProduct(id: 2, title: "Product 2"),
        ]
        let expectedResponse = ProductListResponse(products: products)

        // When
        sut.fetchProducts(for: collectionId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { productMappers in
                    XCTAssertEqual(productMappers.count, 2)
                    XCTAssertEqual(productMappers[0].product_Title, "Product 1")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.fetchProductsSubject.send(expectedResponse)
        mockRemoteDataSource.fetchProductsSubject.send(completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.fetchProductsCallCount, 1)
        XCTAssertEqual(
            mockRemoteDataSource.lastFetchProductsCollectionId, collectionId)
    }

    func testFetchAllProducts_Success() {
        // Given
        let expectation = XCTestExpectation(
            description: "Fetch all products success")
        let products = [
            createMockProduct(id: 1, title: "Product 1"),
            createMockProduct(id: 2, title: "Product 2"),
            createMockProduct(id: 3, title: "Product 3"),
        ]
        let expectedResponse = ProductListResponse(products: products)

        // When
        sut.fetchAllProducts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { productMappers in
                    XCTAssertEqual(productMappers.count, 3)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.fetchAllProductsSubject.send(expectedResponse)
        mockRemoteDataSource.fetchAllProductsSubject.send(completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.fetchAllProductsCallCount, 1)
    }

    // MARK: - Single Product Test

    func testGetSingleProduct_Success() {
        // Given
        let productId: Int64 = 789
        let expectation = XCTestExpectation(description: "Get single product")
        let expectedResponse = SingleProductResponse(
            product: createMockProduct(id: productId, title: "Test Product")
        )

        // When
        sut.getSingleProduct(for: productId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.product.id, productId)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.getSingleProductSubject.send(expectedResponse)
        mockRemoteDataSource.getSingleProductSubject.send(completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.getSingleProductCallCount, 1)
        XCTAssertEqual(mockRemoteDataSource.lastGetSingleProductId, productId)
    }

    // MARK: - Customer Tests

    func testGetCustomers_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Get customers")
        let expectedResponse = AllCustomerResponse(
            customers: [createMockCustomer(id: 1, email: "test@example.com")]
        )

        // When
        sut.getCustomers()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.getCustomersSubject.send(expectedResponse)
        mockRemoteDataSource.getCustomersSubject.send(completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    func testGetSingleCustomer_Success() {
        // Given
        let customerId = "123"
        let expectation = XCTestExpectation(description: "Get single customer")
        let expectedResponse = CustomerResponse(
            customer: createMockCustomer(id: 123, email: "test@example.com")
        )

        // When
        sut.getSingleCustomer(for: customerId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.getSingleCustomerSubject.send(expectedResponse)
        mockRemoteDataSource.getSingleCustomerSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Wishlist Tests

    func testGetWishlistProductsForUser_Success() {
        // Given
        let userId = "user123"
        let expectation = XCTestExpectation(description: "Get wishlist")
        let expectedProducts = [
            WishlistProduct(
                id: "1", productId: "p1", title: "Product 1", bodyHtml: "",
                vendor: nil, productType: "", status: nil, image: nil,
                price: 99.99),
            WishlistProduct(
                id: "2", productId: "p2", title: "Product 2", bodyHtml: "",
                vendor: nil, productType: "", status: nil, image: nil,
                price: 149.99),
        ]

        // When
        sut.getWishlistProductsForUser(whoseId: userId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { products in
                    XCTAssertEqual(products?.count, 2)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockFirebaseDataSource.getWishlistProductsSubject.send(expectedProducts)
        mockFirebaseDataSource.getWishlistProductsSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockFirebaseDataSource.getWishlistProductsCallCount, 1)
        XCTAssertEqual(mockFirebaseDataSource.lastGetWishlistUserId, userId)
    }

    func testAddWishlistProductForUser_Success() {
        // Given
        let userId = "user123"
        let product = WishlistProduct(
            id: "1", productId: "p1", title: "Product", bodyHtml: "",
            vendor: nil, productType: "", status: nil, image: nil, price: 99.99)
        let expectation = XCTestExpectation(description: "Add to wishlist")

        // When
        sut.addWishlistProductForUser(whoseId: userId, withProduct: product)
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Control
        mockFirebaseDataSource.addWishlistProductSubject.send(())
        mockFirebaseDataSource.addWishlistProductSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockFirebaseDataSource.addWishlistProductCallCount, 1)
    }

    func testRemoveWishlistProductForUser_Success() {
        // Given
        let userId = "user123"
        let productId = "product456"
        let expectation = XCTestExpectation(description: "Remove from wishlist")

        // When
        sut.removeWishlistProductForUser(
            whoseId: userId, withProduct: productId
        )
        .sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)

        // Control
        mockFirebaseDataSource.removeWishlistProductSubject.send(())
        mockFirebaseDataSource.removeWishlistProductSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockFirebaseDataSource.removeWishlistProductCallCount, 1)
    }

    func testIsProductInWishlist_ReturnsTrue() {
        // Given
        let userId = "user123"
        let productId = "product456"
        let expectation = XCTestExpectation(description: "Check wishlist")

        // When
        sut.isProductInWishlist(withProduct: productId, forUser: userId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { isInWishlist in
                    XCTAssertTrue(isInWishlist)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockFirebaseDataSource.isProductInWishlistSubject.send(true)
        mockFirebaseDataSource.isProductInWishlistSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Draft Order Tests

    func testFetchAllDraftOrders_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch draft orders")
        let expectedResponse = DraftOrdersResponse(
            draftOrders: [
                createMockDraftOrder(id: 1, email: "test@example.com")
            ]
        )

        // When
        sut.fetchAllDraftOrders()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        // Control
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(expectedResponse)
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    func testPostNewDraftOrder_Success() {
        // Given
        let cartEntity = CartEntity(
            email: "test@example.com", productId: 123, variantId: 456,
            quantity: 2)
        let expectedDraftOrder = createMockDraftOrder(
            id: 999, email: "test@example.com")
        let expectation = XCTestExpectation(description: "Post new draft order")

        // When
        sut.postNewDraftOrder(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { draftOrder in
                    XCTAssertNotNil(draftOrder)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.postNewDraftOrderSubject.send(expectedDraftOrder)
        mockRemoteDataSource.postNewDraftOrderSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    func testEditDraftOrder_Success() {
        // Given
        let draftOrder = createMockDraftOrder(
            id: 123, email: "test@example.com")
        let expectation = XCTestExpectation(description: "Edit draft order")

        // When
        sut.editDraftOrder(draftOrder: draftOrder)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { updatedOrder in
                    XCTAssertNotNil(updatedOrder)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.editExistingDraftOrderSubject.send(draftOrder)
        mockRemoteDataSource.editExistingDraftOrderSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Add to Cart Complex Logic Tests

    func testAddToCart_NewCustomer_CreatesNewDraftOrder() {
        // Given
        let cartEntity = CartEntity(
            email: "new@example.com", productId: 123, variantId: 456,
            quantity: 2)
        let expectation = XCTestExpectation(
            description: "Add to cart - new customer")
        let emptyDraftOrdersResponse = DraftOrdersResponse(draftOrders: [])
        let newDraftOrder = createMockDraftOrder(
            id: 999, email: "new@example.com")

        // When
        sut.addToCart(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { result in
                    XCTAssertEqual(result, CustomSuccess.Added)
                    expectation.fulfill()
                }
            ).store(in: &cancellables)

        // Control - First fetch returns empty
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            emptyDraftOrdersResponse)
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .finished)

        // Then post new draft order
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mockRemoteDataSource.postNewDraftOrderSubject.send(
                newDraftOrder)
            self?.mockRemoteDataSource.postNewDraftOrderSubject.send(
                completion: .finished)
        }

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.postNewDraftOrderCallCount, 1)
    }

    func testAddToCart_ExistingCustomerNewVariant_AddsLineItem() {
        // Given
        let cartEntity = CartEntity(
            email: "existing@example.com", productId: 123, variantId: 789,
            quantity: 1)
        let expectation = XCTestExpectation(
            description: "Add to cart - existing customer new variant")

        let existingLineItem = LineItem(
            id: 1,
            variantId: 456,
            productId: 123,
            title: "Existing Product",
            variantTitle: "Small",
            quantity: 2
        )

        let existingDraftOrder = DraftOrder(
            id: 100,
            email: "existing@example.com",
            status: "open",
            lineItems: [existingLineItem]
        )

        let draftOrdersResponse = DraftOrdersResponse(draftOrders: [
            existingDraftOrder
        ])

        // When
        sut.addToCart(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { result in
                    XCTAssertEqual(result, CustomSuccess.Added)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control - First fetch returns existing order
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            draftOrdersResponse)
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .finished)

        // Then edit draft order
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mockRemoteDataSource.editExistingDraftOrderSubject.send(
                existingDraftOrder)
            self?.mockRemoteDataSource.editExistingDraftOrderSubject.send(
                completion: .finished)
        }

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.editExistingDraftOrderCallCount, 1)
    }

    func testAddToCart_ExistingCustomerExistingVariant_UpdatesQuantity() {
        // Given
        let cartEntity = CartEntity(
            email: "existing@example.com", productId: 123, variantId: 456,
            quantity: 5)
        let expectation = XCTestExpectation(
            description: "Add to cart - update existing variant")

        let existingLineItem = LineItem(
            id: 1,
            variantId: 456,
            productId: 123,
            title: "Existing Product",
            variantTitle: "Medium",
            quantity: 2
        )

        let existingDraftOrder = DraftOrder(
            id: 100,
            email: "existing@example.com",
            status: "open",
            lineItems: [existingLineItem]
        )

        let draftOrdersResponse = DraftOrdersResponse(draftOrders: [
            existingDraftOrder
        ])

        // When
        sut.addToCart(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { result in
                    XCTAssertEqual(result, CustomSuccess.AlreadyExist)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control - First fetch returns existing order with same variant
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            draftOrdersResponse)
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .finished)

        // Then edit draft order
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.mockRemoteDataSource.editExistingDraftOrderSubject.send(
                existingDraftOrder)
            self?.mockRemoteDataSource.editExistingDraftOrderSubject.send(
                completion: .finished)
        }

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockRemoteDataSource.editExistingDraftOrderCallCount, 1)
    }

    func testAddToCart_FetchDraftOrdersFails_ReturnsError() {
        // Given
        let cartEntity = CartEntity(
            email: "test@example.com", productId: 123, variantId: 456,
            quantity: 1)
        let expectation = XCTestExpectation(
            description: "Add to cart - fetch fails")

        // When
        sut.addToCart(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertNotNil(error)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .failure(MockError.generic))

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Get All Draft Orders For Customer Tests

    func testGetAllDraftOrdersForCustomer_Success() {
        // Given
        let expectation = XCTestExpectation(
            description: "Get customer draft orders")

        // Mock user session
        let mockUserSession = MockUserSessionService()
        mockUserSession.currentUserEmailToReturn = "customer@example.com"

        // Create draft orders
        let customerDraftOrder = DraftOrder(
            id: 1,
            email: "customer@example.com",
            status: "open",
            lineItems: [
                LineItem(
                    id: 1,
                    variantId: 123,
                    productId: 456,
                    title: "Product",
                    variantTitle: "Medium",
                    quantity: 2,
                    price: "99.99"
                )
            ]
        )

        let otherDraftOrder = DraftOrder(
            id: 2,
            email: "other@example.com",
            status: "open",
            lineItems: []
        )

        let draftOrdersResponse = DraftOrdersResponse(draftOrders: [
            customerDraftOrder, otherDraftOrder,
        ])

        // When
        sut.getAllDraftOrdersForCustomer()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { cartMappers in
                    XCTAssertEqual(cartMappers.count, 0)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Control
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            draftOrdersResponse)
        mockRemoteDataSource.fetchAllDraftOrdersSubject.send(
            completion: .finished)

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }


    // MARK: - Helper Methods

    private func createMockProduct(id: Int64, title: String) -> Product {
        return Product(
            id: id,
            title: title,
            bodyHtml: "<p>Test</p>",
            vendor: "Test Vendor",
            productType: "Test Type",
            createdAt: "2024-01-01",
            handle: "test-product",
            updatedAt: "2024-01-01",
            publishedAt: "2024-01-01",
            templateSuffix: nil,
            publishedScope: "web",
            tags: "test",
            status: "active",
            adminGraphqlApiId: "gid://shopify/Product/\(id)",
            variants: [
                Variant(
                    id: id * 100,
                    productId: id,
                    title: "Default",
                    price: "99.99",
                    position: 1,
                    inventoryPolicy: "deny",
                    compareAtPrice: nil,
                    option1: "Default",
                    option2: nil,
                    option3: nil,
                    createdAt: "2024-01-01",
                    updatedAt: "2024-01-01",
                    taxable: true,
                    barcode: nil,
                    fulfillmentService: "manual",
                    grams: 100,
                    inventoryManagement: "shopify",
                    requiresShipping: true,
                    sku: "SKU-\(id)",
                    weight: 0.1,
                    weightUnit: "kg",
                    inventoryItemId: id * 1000,
                    inventoryQuantity: 10,
                    oldInventoryQuantity: 10,
                    adminGraphqlApiId:
                        "gid://shopify/ProductVariant/\(id * 100)",
                    imageId: nil
                )
            ],
            options: [],
            images: [],
            image: ProductImage(
                id: id * 10,
                alt: title,
                position: 1,
                productId: id,
                createdAt: "2024-01-01",
                updatedAt: "2024-01-01",
                adminGraphqlApiId: "gid://shopify/ProductImage/\(id * 10)",
                width: 1000,
                height: 1000,
                src: "https://example.com/image.jpg",
                variantIds: []
            )
        )
    }

    private func createMockCustomer(id: Int64, email: String) -> Customer {
        return Customer(
            id: id,
            email: email,
            createdAt: "2024-01-01",
            updatedAt: "2024-01-01",
            firstName: "Test",
            lastName: "Customer",
            ordersCount: 0,
            state: "enabled",
            totalSpent: "0.00",
            lastOrderId: nil,
            note: nil,
            verifiedEmail: true,
            multipassIdentifier: nil,
            taxExempt: false,
            tags: "",
            lastOrderName: nil,
            currency: "USD",
            phone: nil,
            addresses: [],
            emailMarketingConsent: nil,
            smsMarketingConsent: nil,
            adminGraphqlApiId: "gid://shopify/Customer/\(id)"
        )
    }

    private func createMockDraftOrder(
        id: Int64, email: String, status: String = "open"
    ) -> DraftOrder {
        return DraftOrder(
            id: id,
            note: nil,
            email: email,
            taxesIncluded: true,
            currency: "USD",
            invoiceSentAt: nil,
            createdAt: "2024-01-01",
            updatedAt: "2024-01-01",
            taxExempt: false,
            completedAt: nil,
            name: "Draft Order #\(id)",
            allowDiscountCodesInCheckout: true,
            b2b: false,
            status: status,
            lineItems: [],
            apiClientId: nil,
            shippingAddress: nil,
            billingAddress: nil,
            invoiceUrl: nil,
            createdOnApiVersionHandle: nil,
            appliedDiscount: nil,
            orderId: nil,
            shippingLine: nil,
            taxLines: [],
            tags: "",
            noteAttributes: [],
            totalPrice: "0.00",
            subtotalPrice: "0.00",
            totalTax: "0.00",
            paymentTerms: nil,
            adminGraphqlApiId: "gid://shopify/DraftOrder/\(id)",
            customer: nil
        )
    }
}

// MARK: - Mock Remote Data Source

class MockRemoteDataSource: RemoteDataSourceProtocol {
    // Fetch Brands
    var fetchBrandsCallCount = 0
    let fetchBrandsSubject = PassthroughSubject<
        SmartCollectionsResponse?, Error
    >()

    func fetchBrands() -> AnyPublisher<SmartCollectionsResponse?, Error> {
        fetchBrandsCallCount += 1
        return fetchBrandsSubject.eraseToAnyPublisher()
    }

    // Fetch Products
    var fetchProductsCallCount = 0
    var lastFetchProductsCollectionId: Int64?
    let fetchProductsSubject = PassthroughSubject<ProductListResponse?, Error>()

    func fetchProducts(from collection_id: Int64) -> AnyPublisher<
        ProductListResponse?, Error
    > {
        fetchProductsCallCount += 1
        lastFetchProductsCollectionId = collection_id
        return fetchProductsSubject.eraseToAnyPublisher()
    }

    // Fetch All Products
    var fetchAllProductsCallCount = 0
    let fetchAllProductsSubject = PassthroughSubject<
        ProductListResponse?, Error
    >()

    func fetchAllProducts() -> AnyPublisher<ProductListResponse?, Error> {
        fetchAllProductsCallCount += 1
        return fetchAllProductsSubject.eraseToAnyPublisher()
    }

    // Get Single Product
    var getSingleProductCallCount = 0
    var lastGetSingleProductId: Int64?
    let getSingleProductSubject = PassthroughSubject<
        SingleProductResponse?, Error
    >()

    func getSingleProduct(for productId: Int64) -> AnyPublisher<
        SingleProductResponse?, Error
    > {
        getSingleProductCallCount += 1
        lastGetSingleProductId = productId
        return getSingleProductSubject.eraseToAnyPublisher()
    }

    // Get Customers
    var getCustomersCallCount = 0
    let getCustomersSubject = PassthroughSubject<AllCustomerResponse?, Error>()

    func getCustomers() -> AnyPublisher<AllCustomerResponse?, Error> {
        getCustomersCallCount += 1
        return getCustomersSubject.eraseToAnyPublisher()
    }

    // Get Single Customer
    var getSingleCustomerCallCount = 0
    var lastGetSingleCustomerId: String?
    let getSingleCustomerSubject = PassthroughSubject<
        CustomerResponse?, Error
    >()

    func getSingleCustomer(for customerId: String) -> AnyPublisher<
        CustomerResponse?, Error
    > {
        getSingleCustomerCallCount += 1
        lastGetSingleCustomerId = customerId
        return getSingleCustomerSubject.eraseToAnyPublisher()
    }

    // Fetch All Draft Orders
    var fetchAllDraftOrdersCallCount = 0
    let fetchAllDraftOrdersSubject = PassthroughSubject<
        DraftOrdersResponse?, Error
    >()

    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error> {
        fetchAllDraftOrdersCallCount += 1
        return fetchAllDraftOrdersSubject.eraseToAnyPublisher()
    }

    // Post New Draft Order
    var postNewDraftOrderCallCount = 0
    var lastPostNewDraftOrderCartEntity: CartEntity?
    let postNewDraftOrderSubject = PassthroughSubject<DraftOrder?, Error>()

    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<
        DraftOrder?, Error
    > {
        postNewDraftOrderCallCount += 1
        lastPostNewDraftOrderCartEntity = cartEntity
        return postNewDraftOrderSubject.eraseToAnyPublisher()
    }

    // Edit Existing Draft Order
    var editExistingDraftOrderCallCount = 0
    var lastEditExistingDraftOrder: DraftOrder?
    let editExistingDraftOrderSubject = PassthroughSubject<DraftOrder?, Error>()

    func editExistingDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<
        DraftOrder?, Error
    > {
        editExistingDraftOrderCallCount += 1
        lastEditExistingDraftOrder = draftOrder
        return editExistingDraftOrderSubject.eraseToAnyPublisher()
    }
}
	
