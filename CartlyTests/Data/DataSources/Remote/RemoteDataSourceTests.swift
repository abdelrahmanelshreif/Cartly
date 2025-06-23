//
//  MockRemoteDataSource.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 14/6/25.
//

import XCTest
import Combine
@testable import Cartly

final class RemoteDataSourceTests: XCTestCase {
    
    var sut: RemoteDataSourceImpl!
    var mockNetworkService: MockNetworkService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = RemoteDataSourceImpl(networkService: mockNetworkService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Brands Tests
    
    func testFetchBrands_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch brands success")
        let expectedResponse = SmartCollectionsResponse(
            smartCollections: [
                SmartCollection(
                    id: 1,
                    handle: "nike",
                    title: "Nike",
                    updatedAt: "2024-01-01",
                    bodyHtml: "Nike collection",
                    publishedAt: "2024-01-01",
                    sortOrder: "alpha",
                    templateSuffix: nil,
                    disjunctive: false,
                    rules: [],
                    publishedScope: "web",
                    adminGraphqlApiId: "gid://shopify/Collection/1",
                    image: CollectionImage(
                        createdAt: "2024-01-01",
                        alt: "Nike",
                        width: 1000,
                        height: 1000,
                        src: "https://example.com/nike.jpg"
                    )
                ),
                SmartCollection(
                    id: 2,
                    handle: "adidas",
                    title: "Adidas",
                    updatedAt: "2024-01-01",
                    bodyHtml: "Adidas collection",
                    publishedAt: "2024-01-01",
                    sortOrder: "alpha",
                    templateSuffix: nil,
                    disjunctive: false,
                    rules: [],
                    publishedScope: "web",
                    adminGraphqlApiId: "gid://shopify/Collection/2",
                    image: nil
                )
            ]
        )
        
        // When
        sut.fetchBrands()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.smartCollections?.count, 2)
                    XCTAssertEqual(response?.smartCollections?[0].title, "Nike")
                    XCTAssertEqual(response?.smartCollections?[1].title, "Adidas")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNetworkService.requestCalled)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/smart_collections.json")
	    }
    
    func testFetchBrands_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch brands failure")
        
        // When
        sut.fetchBrands()
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
        mockNetworkService.responseSubject.send(completion: .failure(MockError.generic))
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Fetch Products Tests
    
    func testFetchProductsFromCollection_Success() {
        // Given
        let collectionId: Int64 = 12345
        let expectation = XCTestExpectation(description: "Fetch products from collection")
        let expectedResponse = ProductListResponse(
            products: [
                createMockProduct(id: 1, title: "Product 1", price: "99.99"),
                createMockProduct(id: 2, title: "Product 2", price: "149.99")
            ]
        )
        
        // When
        sut.fetchProducts(from: collectionId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.products.count, 2)
                    XCTAssertEqual(response?.products[0].title, "Product 1")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/products.json?collection_id=\(collectionId)")
    }
    
    func testFetchAllProducts_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch all products")
        let expectedResponse = ProductListResponse(
            products: [
                createMockProduct(id: 1, title: "All Product 1", price: "99.99"),
                createMockProduct(id: 2, title: "All Product 2", price: "149.99"),
                createMockProduct(id: 3, title: "All Product 3", price: "199.99")
            ]
        )
        
        // When
        sut.fetchAllProducts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.products.count, 3)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/products.json")
    }
    
    // MARK: - Get Single Product Tests
    
    func testGetSingleProduct_Success() {
        // Given
        let productId: Int64 = 789
        let expectation = XCTestExpectation(description: "Get single product")
        let expectedResponse = SingleProductResponse(
            product: createMockProduct(id: productId, title: "Test Product", price: "299.99")
        )
        
        // When
        sut.getSingleProduct(for: productId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.product.id, productId)
                    XCTAssertEqual(response?.product.title, "Test Product")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/products/\(productId).json")
    }
    
    // MARK: - Customer Tests
    
    func testGetCustomers_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Get all customers")
        let expectedResponse = AllCustomerResponse(
            customers: [
                createMockCustomer(id: 1, email: "customer1@example.com"),
                createMockCustomer(id: 2, email: "customer2@example.com")
            ]
        )
        
        // When
        sut.getCustomers()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.customers.count, 2)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/customers.json")
    }
    
    func testGetSingleCustomer_Success() {
        // Given
        let customerId = "123456"
        let expectation = XCTestExpectation(description: "Get single customer")
        let expectedResponse = CustomerResponse(
            customer: createMockCustomer(id: 123456, email: "test@example.com")
        )
        
        // When
        sut.getSingleCustomer(for: customerId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.customer?.email, "test@example.com")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/customers/\(customerId).json")
    }
    
    // MARK: - Draft Order Tests
    
    func testFetchAllDraftOrders_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch all draft orders")
        let expectedResponse = DraftOrdersResponse(
            draftOrders: [
                createMockDraftOrder(id: 1, email: "test1@example.com", status: "open"),
                createMockDraftOrder(id: 2, email: "test2@example.com", status: "closed")
            ]
        )
        
        // When
        sut.fetchAllDraftOrders()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.draftOrders?.count, 2)
                    XCTAssertEqual(response?.draftOrders?[0].status, "open")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        mockNetworkService.responseSubject.send(expectedResponse)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/draft_orders.json")
    }
    
    func testPostNewDraftOrder_Success() {
        // Given
        let cartEntity = CartEntity(
            email: "test@example.com",
            productId: 12345,
            variantId: 67890,
            quantity: 2
        )
        let expectedDraftOrder = createMockDraftOrder(
            id: 999,
            email: "test@example.com",
            status: "open"
        )
        let expectation = XCTestExpectation(description: "Post new draft order")
        
        // When
        sut.postNewDraftOrder(cartEntity: cartEntity)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { draftOrder in
                    XCTAssertNotNil(draftOrder)
                    XCTAssertEqual(draftOrder?.email, "test@example.com")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        let response = DraftOrderResponse(draftOrder: expectedDraftOrder)
        mockNetworkService.responseSubject.send(response)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/draft_orders.json")
        
        // Verify parameters
        if let parameters = mockNetworkService.requestParameters?.parameters as? [String: Any],
           let draftOrderParams = parameters["draft_order"] as? [String: Any] {
            XCTAssertEqual(draftOrderParams["email"] as? String, cartEntity.email)
            XCTAssertEqual(draftOrderParams["fulfillment_status"] as? String, "fulfilled")
            XCTAssertEqual(draftOrderParams["send_receipt"] as? Bool, true)
            XCTAssertEqual(draftOrderParams["send_fulfillment_receipt"] as? Bool, true)
            
            if let lineItems = draftOrderParams["line_items"] as? [[String: Any]],
               let firstItem = lineItems.first {
                XCTAssertEqual(firstItem["product_id"] as? Int64, cartEntity.productId)
                XCTAssertEqual(firstItem["variant_id"] as? Int64, cartEntity.variantId)
                XCTAssertEqual(firstItem["quantity"] as? Int, cartEntity.quantity)
            }
        } else {
            XCTFail("Parameters not properly formatted")
        }
    }
    
    func testEditExistingDraftOrder_Success() {
        // Given
        let lineItem = LineItem(
            id: 1,
            variantId: 123,
            productId: 456,
            title: "Test Product",
            variantTitle: "Medium",
            sku: "SKU123",
            vendor: "Test Vendor",
            quantity: 2,
            requiresShipping: true,
            taxable: true,
            giftCard: false,
            fulfillmentService: "manual",
            grams: 100,
            taxLines: [],
            appliedDiscount: nil,
            name: "Test Product - Medium",
            properties: [],
            custom: false,
            price: "99.99"
        )
        
        let draftOrder = DraftOrder(
            id: 123,
            note: "Test note",
            email: "updated@example.com",
            taxesIncluded: true,
            currency: "USD",
            invoiceSentAt: nil,
            createdAt: "2024-01-01",
            updatedAt: "2024-01-01",
                        taxExempt: false,
            completedAt: nil,
            name: "Draft Order #123",
            allowDiscountCodesInCheckout: true,
            b2b: false,
            status: "open",
            lineItems: [lineItem],
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
            totalPrice: "199.98",
            subtotalPrice: "199.98",
            totalTax: "0.00",
            paymentTerms: nil,
            adminGraphqlApiId: "gid://shopify/DraftOrder/123",
            customer: nil
        )
        
        let expectation = XCTestExpectation(description: "Edit existing draft order")
        
        // When
        sut.editExistingDraftOrder(draftOrder: draftOrder)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { updatedOrder in
                    XCTAssertNotNil(updatedOrder)
                    XCTAssertEqual(updatedOrder?.id, 123)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Control
        let response = DraftOrderResponse(draftOrder: draftOrder)
        mockNetworkService.responseSubject.send(response)
        mockNetworkService.responseSubject.send(completion: .finished)
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockNetworkService.requestParameters?.path, "/draft_orders/123.json")
        
        // Verify parameters structure
        if let parameters = mockNetworkService.requestParameters?.parameters as? [String: Any],
           let draftOrderParams = parameters["draft_order"] as? [String: Any] {
            XCTAssertEqual(draftOrderParams["email"] as? String, draftOrder.email)
            XCTAssertEqual(draftOrderParams["status"] as? String, draftOrder.status)
            XCTAssertEqual(draftOrderParams["note"] as? String, draftOrder.note)
            XCTAssertNotNil(draftOrderParams["line_items"])
        }
    }
    
    func testEditExistingDraftOrder_Failure() {
        // Given
        let draftOrder = createMockDraftOrder(id: 123, email: "test@example.com", status: "open")
        let expectation = XCTestExpectation(description: "Edit draft order failure")
        
        // When
        sut.editExistingDraftOrder(draftOrder: draftOrder)
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
        mockNetworkService.responseSubject.send(completion: .failure(MockError.generic))
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Helper Methods
    
    private func createMockProduct(id: Int64, title: String, price: String) -> Product {
        return Product(
            id: id,
            title: title,
            bodyHtml: "<p>Test product</p>",
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
                    price: price,
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
                    adminGraphqlApiId: "gid://shopify/ProductVariant/\(id * 100)",
                    imageId: nil
                )
            ],
            options: [],
            images: [],
            image: nil
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
    
    private func createMockDraftOrder(id: Int64, email: String, status: String) -> DraftOrder {
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
