//
//  ProductsViewModelTests.swift
//  CartlyTests
//
//  Created by Khaled Mustafa on 26/06/2025.
//

@testable import Cartly
import Combine
import Foundation
import XCTest

final class ProductsViewModelTests: XCTestCase {
    var sut: ProductsViewModel!
    var mockUseCase: MockGetProductsForBrandId!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = MockGetProductsForBrandId()
        sut = ProductsViewModel(useCase: mockUseCase)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialization() {
        let viewModel = ProductsViewModel(useCase: mockUseCase)
        XCTAssertNotNil(viewModel)
        let mirror = Mirror(reflecting: viewModel)
        let productStateChild = mirror.children.first { $0.label == "productState" }
        if let productState = productStateChild?.value as? ResultState<[ProductMapper]> {
            switch productState {
            case .loading:
                XCTAssertTrue(true, "Initial state should be loading")
            default:
                XCTFail("Initial state should be loading")
            }
        }
    }

    func testLoadProducts_Success() {
        let brandId: Int64 = 12345
        let expectedProducts = createMockProducts()
        let expectation = XCTestExpectation(description: "Products loaded successfully")
        mockUseCase.mockResult = .success(expectedProducts)
        var receivedState: ResultState<[ProductMapper]>?
        sut.$productState
            .dropFirst()
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)
        sut.loadProducts(brandId: brandId)
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockUseCase.executeCalled)
        XCTAssertEqual(mockUseCase.executeBrandId, brandId)
        if case let .success(products) = receivedState {
            XCTAssertEqual(products.count, expectedProducts.count)
            XCTAssertEqual(products[0].product_Title, expectedProducts[0].product_Title)
            XCTAssertEqual(products[1].product_Title, expectedProducts[1].product_Title)
        } else {
            XCTFail("Expected success state but got \(String(describing: receivedState))")
        }
    }

    func testLoadProducts_Success_EmptyList() {
        let brandId: Int64 = 67890
        let emptyProducts: [ProductMapper] = []
        let expectation = XCTestExpectation(description: "Empty products list loaded")
        mockUseCase.mockResult = .success(emptyProducts)
        var receivedState: ResultState<[ProductMapper]>?
        sut.$productState
            .dropFirst()
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadProducts(brandId: brandId)
        wait(for: [expectation], timeout: 2.0)
        if case let .success(products) = receivedState {
            XCTAssertEqual(products.count, 0)
        } else {
            XCTFail("Expected success state with empty array")
        }
    }

    func testLoadProducts_Failure() {
        let brandId: Int64 = 12345
        let expectedError = ErrorType.noData
        let expectation = XCTestExpectation(description: "Products loading failed")
        mockUseCase.mockResult = .failure(expectedError)
        var receivedState: ResultState<[ProductMapper]>?
        sut.$productState
            .dropFirst()
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)
        sut.loadProducts(brandId: brandId)
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockUseCase.executeCalled)
        XCTAssertEqual(mockUseCase.executeBrandId, brandId)
        if case let .failure(errorMessage) = receivedState {
            XCTAssertEqual(errorMessage, expectedError.localizedDescription)
        } else {
            XCTFail("Expected failure state but got \(String(describing: receivedState))")
        }
    }

    func testMemoryManagement_WeakSelfInClosures() {
        let brandId: Int64 = 12345
        weak var weakViewModel = sut
        mockUseCase.mockResult = .success(createMockProducts())
        sut.loadProducts(brandId: brandId)
        sut = nil
        let expectation = XCTestExpectation(description: "Memory cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    private func createMockProducts(startId: Int64 = 1) -> [ProductMapper] {
        return [
            ProductMapper(from: createMockProduct(id: startId, title: "Test Product \(startId)", price: "99.99")),
            ProductMapper(from: createMockProduct(id: startId + 1, title: "Test Product \(startId + 1)", price: "149.99")),
            ProductMapper(from: createMockProduct(id: startId + 2, title: "Test Product \(startId + 2)", price: "199.99")),
        ]
    }

    private func createMockProduct(id: Int64, title: String, price: String) -> Product {
        return Product(
            id: id,
            title: title,
            bodyHtml: "Test product description",
            vendor: "Test Vendor",
            productType: "Test Type",
            createdAt: "2024-01-01T00:00:00Z",
            handle: "test-product-\(id)",
            updatedAt: "2024-01-01T00:00:00Z",
            publishedAt: "2024-01-01T00:00:00Z",
            templateSuffix: nil,
            publishedScope: "web",
            tags: "test, mock",
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
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: "2024-01-01T00:00:00Z",
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
                ),
            ],
            options: [],
            images: [],
            image: ProductImage(
                id: id * 10,
                alt: "Test product image",
                position: 1,
                productId: id,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z",
                adminGraphqlApiId: "gid://shopify/ProductImage/\(id * 10)",
                width: 1000,
                height: 1000,
                src: "https://example.com/product-\(id).jpg",
                variantIds: [id * 100]
            )
        )
    }
}
