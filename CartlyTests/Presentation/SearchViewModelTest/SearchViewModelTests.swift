@testable import Cartly
import Combine
import Foundation
import XCTest

final class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!
    var mockRepository: MockRepositoryForSearch!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        mockRepository = MockRepositoryForSearch()
        let useCase = GetAllProductsUseCase(repository: mockRepository)
        viewModel = SearchViewModel(allProductsUseCase: useCase)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.productsState, .loading)
        XCTAssertEqual(viewModel.cartState, .loading)
        XCTAssertEqual(viewModel.searchedText, "")
        XCTAssertEqual(viewModel.minPrice, 0)
        XCTAssertEqual(viewModel.maxPrice, 100)
        XCTAssertEqual(viewModel.currentMinPrice, 0)
        XCTAssertEqual(viewModel.currentMaxPrice, 100)
        XCTAssertTrue(viewModel.filteratedProducts.isEmpty)
    }

    func testLoadProductsSuccess() {
        let expectedProducts = createMockProducts()
        mockRepository.mockProducts = expectedProducts
        let expectation = XCTestExpectation(description: "Products loaded successfully")
        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case let .success(products) = state {
                    XCTAssertEqual(products.count, expectedProducts.count)
                    XCTAssertEqual(products.first?.product_Title, "iPhone 13")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadProductsFailure() {
        mockRepository.shouldReturnError = true
        let expectation = XCTestExpectation(description: "Products loading failed")
        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case let .failure(error) = state {
                    XCTAssertEqual(error, "Mock error occurred")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchFiltering() {
        let products = createMockProducts()
        mockRepository.mockProducts = products

        let expectation = XCTestExpectation(description: "Products loaded for search test")

        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        viewModel.searchedText = "iPhone"

        let filteredProducts = viewModel.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts.first?.product_Title, "iPhone 13")
    }

    func testSearchCaseInsensitive() {
        let products = createMockProducts()
        mockRepository.mockProducts = products

        let expectation = XCTestExpectation(description: "Products loaded for case insensitive test")

        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        viewModel.searchedText = "iphone"

        let filteredProducts = viewModel.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts.first?.product_Title, "iPhone 13")
    }

    func testPriceFiltering() {
        let products = createMockProductsWithVariousPrices()
        mockRepository.mockProducts = products

        let expectation = XCTestExpectation(description: "Products loaded for price filtering test")

        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        viewModel.currentMinPrice = 50.0
        viewModel.currentMaxPrice = 500.0

        let filteredProducts = viewModel.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts.first?.product_Title, "MacBook Pro")
    }

    func testCombinedSearchAndPriceFiltering() {
        let products = createMockProductsWithVariousPrices()
        mockRepository.mockProducts = products

        let expectation = XCTestExpectation(description: "Products loaded for combined filtering test")

        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        viewModel.searchedText = "iPhone"
        viewModel.currentMinPrice = 800.0
        viewModel.currentMaxPrice = 1200.0

        let filteredProducts = viewModel.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts.first?.product_Title, "iPhone 14 Pro")
    }

    func testEmptySearchResults() {
        let products = createMockProducts()
        mockRepository.mockProducts = products

        let expectation = XCTestExpectation(description: "Products loaded for empty search test")

        viewModel.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        viewModel.searchedText = "NonExistentProduct"

        let filteredProducts = viewModel.filteratedProducts
        XCTAssertTrue(filteredProducts.isEmpty)
    }

    private func createMockProducts() -> [ProductMapper] {
        let products = [
            createMockProduct(
                id: 1,
                title: "iPhone 13",
                productType: "Electronics",
                vendor: "Apple",
                imageSrc: "iphone13.jpg",
                price: "699.00"
            ),
            createMockProduct(
                id: 2,
                title: "Samsung Galaxy S21",
                productType: "Electronics",
                vendor: "Samsung",
                imageSrc: "galaxy21.jpg",
                price: "799.00"
            ),
            createMockProduct(
                id: 3,
                title: "MacBook Pro",
                productType: "Computers",
                vendor: "Apple",
                imageSrc: "macbook.jpg",
                price: "1299.00"
            ),
        ]

        return products.map { ProductMapper(from: $0) }
    }

    private func createMockProductsWithVariousPrices() -> [ProductMapper] {
        let products = [
            createMockProduct(
                id: 1,
                title: "iPhone 13",
                productType: "Electronics",
                vendor: "Apple",
                imageSrc: "iphone13.jpg",
                price: "699.00"
            ),
            createMockProduct(
                id: 2,
                title: "iPhone 14 Pro",
                productType: "Electronics",
                vendor: "Apple",
                imageSrc: "iphone14.jpg",
                price: "999.00"
            ),
            createMockProduct(
                id: 3,
                title: "MacBook Pro",
                productType: "Computers",
                vendor: "Apple",
                imageSrc: "macbook.jpg",
                price: "299.00"
            ),
            createMockProduct(
                id: 4,
                title: "AirPods",
                productType: "Accessories",
                vendor: "Apple",
                imageSrc: "airpods.jpg",
                price: "10.00"
            ),
            createMockProduct(
                id: 5,
                title: "iPad Pro",
                productType: "Tablets",
                vendor: "Apple",
                imageSrc: "ipad.jpg",
                price: "1000.00"
            ),
        ]

        return products.map { ProductMapper(from: $0) }
    }

    private func createMockProduct(
        id: Int64,
        title: String,
        productType: String,
        vendor: String,
        imageSrc: String,
        price: String
    ) -> Product {
        let variant = Variant(
            id: id * 10,
            productId: id,
            title: "Default Title",
            price: price,
            position: 1,
            inventoryPolicy: nil,
            compareAtPrice: nil,
            option1: nil,
            option2: nil,
            option3: nil,
            createdAt: nil,
            updatedAt: nil,
            taxable: nil,
            barcode: nil,
            fulfillmentService: nil,
            grams: nil,
            inventoryManagement: nil,
            requiresShipping: nil,
            sku: nil,
            weight: nil,
            weightUnit: nil,
            inventoryItemId: nil,
            inventoryQuantity: nil,
            oldInventoryQuantity: nil,
            adminGraphqlApiId: nil,
            imageId: nil
        )

        let image = ProductImage(
            id: id * 100,
            alt: nil,
            position: 1,
            productId: id,
            createdAt: nil,
            updatedAt: nil,
            adminGraphqlApiId: nil,
            width: nil,
            height: nil,
            src: imageSrc,
            variantIds: nil
        )

        return Product(
            id: id,
            title: title,
            bodyHtml: nil,
            vendor: vendor,
            productType: productType,
            createdAt: nil,
            handle: nil,
            updatedAt: nil,
            publishedAt: nil,
            templateSuffix: nil,
            publishedScope: nil,
            tags: nil,
            status: nil,
            adminGraphqlApiId: nil,
            variants: [variant],
            options: nil,
            images: nil,
            image: image
        )
    }
}
