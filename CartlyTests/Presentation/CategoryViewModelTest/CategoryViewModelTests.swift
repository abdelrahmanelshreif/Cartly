@testable import Cartly
import Combine
import XCTest

final class CategoryViewModelTests: XCTestCase {
    private var sut: CategoryViewModel!
    private var mockAllProductsUseCase: MockGetAllProductsUseCase!
    private var mockCategoryUseCase: MockGetProductsForCategoryId!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAllProductsUseCase = MockGetAllProductsUseCase()
        mockCategoryUseCase = MockGetProductsForCategoryId()
        cancellables = Set<AnyCancellable>()

        sut = CategoryViewModel(
            allProductsUseCase: mockAllProductsUseCase,
            getProductByCategoryUsecase: mockCategoryUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockAllProductsUseCase = nil
        mockCategoryUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    private func createMockProduct(
        id: Int64,
        title: String,
        type: String = "SHOES",
        vendor: String = "Nike",
        image: String = "test-image.jpg",
        price: String = "99.99"
    ) -> ProductMapper {
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

        let productImage = ProductImage(
            id: id * 100,
            alt: nil,
            position: 1,
            productId: id,
            createdAt: nil,
            updatedAt: nil,
            adminGraphqlApiId: nil,
            width: nil,
            height: nil,
            src: image,
            variantIds: nil
        )

        let product = Product(
            id: id,
            title: title,
            bodyHtml: nil,
            vendor: vendor,
            productType: type,
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
            image: productImage
        )

        return ProductMapper(from: product)
    }

    func testInitialState() {
        XCTAssertEqual(sut.productsState, .loading)
        XCTAssertEqual(sut.cartState, .loading)
        XCTAssertEqual(sut.searchedText, "")
        XCTAssertEqual(sut.selectedProductType, .all)
        XCTAssertEqual(sut.selectedCategory, .all)
        XCTAssertEqual(sut.minPrice, 0)
        XCTAssertEqual(sut.maxPrice, 100)
        XCTAssertEqual(sut.currentMinPrice, 0)
        XCTAssertEqual(sut.currentMaxPrice, 100)
        XCTAssertFalse(sut.showingCategorySheet)
        XCTAssertTrue(sut.filteratedProducts.isEmpty)
    }

    func testLoadsProducts_Success() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Product 1", price: "50.0"),
            createMockProduct(id: 2, title: "Product 2", price: "150.0"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded successfully")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case let .success(products) = state {
                    XCTAssertEqual(products.count, 2)
                    XCTAssertEqual(products[0].product_Title, "Product 1")
                    XCTAssertEqual(products[1].product_Title, "Product 2")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockAllProductsUseCase.executeCallCount, 1)
        XCTAssertEqual(sut.minPrice, 50.0)
        XCTAssertEqual(sut.maxPrice, 150.0)
        XCTAssertEqual(sut.currentMinPrice, 50.0)
        XCTAssertEqual(sut.currentMaxPrice, 150.0)
    }

    func testLoadsProducts_Failure() {
        mockAllProductsUseCase.shouldReturnError = true
        mockAllProductsUseCase.errorToReturn = NSError(
            domain: "TestError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Products not found"]
        )

        let expectation = expectation(description: "Products loading failed")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case let .failure(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "Products not found")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockAllProductsUseCase.executeCallCount, 1)
    }

    func testLoadProductsByCategory_WithValidCategoryId() {
        let categoryId: Int64 = 123
        let mockProducts = [
            createMockProduct(id: 1, title: "Category Product 1"),
            createMockProduct(id: 2, title: "Category Product 2"),
        ]
        mockCategoryUseCase.mockProductsByCategory[categoryId] = mockProducts

        let expectation = expectation(description: "Category products loaded")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case let .success(products) = state {
                    XCTAssertEqual(products.count, 2)
                    XCTAssertEqual(products[0].product_Title, "Category Product 1")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadProductsByCategory(categoryId: categoryId)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockCategoryUseCase.executeCallCount, 1)
        XCTAssertEqual(mockCategoryUseCase.lastCategoryId, categoryId)
    }

    func testLoadProductsByCategory_WithZeroCategoryId_CallsLoadAllProducts() {
        let mockProducts = [createMockProduct(id: 1, title: "All Products")]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "All products loaded for category 0")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadProductsByCategory(categoryId: 0)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockAllProductsUseCase.executeCallCount, 1)
        XCTAssertEqual(mockCategoryUseCase.executeCallCount, 0)
    }

    func testLoadProductsByCategory_Failure() {
        let categoryId: Int64 = 123
        mockCategoryUseCase.shouldReturnError = true
        mockCategoryUseCase.errorToReturn = NSError(
            domain: "TestError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Category loading failed"]
        )

        let expectation = expectation(description: "Category loading failed")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case let .failure(errorMessage) = state {
                    XCTAssertEqual(errorMessage, "Category loading failed")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadProductsByCategory(categoryId: categoryId)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockCategoryUseCase.executeCallCount, 1)
        XCTAssertEqual(mockCategoryUseCase.lastCategoryId, categoryId)
    }

    func testFilteratedProducts_BySearchText() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Nike Air Max"),
            createMockProduct(id: 2, title: "Adidas Boost"),
            createMockProduct(id: 3, title: "Nike Revolution"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded for filtering")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        sut.searchedText = "Nike"

        let filteredProducts = sut.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 2)
        XCTAssertTrue(filteredProducts.allSatisfy { $0.product_Title.contains("Nike") })
    }

    func testFilteratedProducts_ByProductType() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Product 1", type: "SHOES"),
            createMockProduct(id: 2, title: "Product 2", type: "T-SHIRTS"),
            createMockProduct(id: 3, title: "Product 3", type: "SHOES"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded for filtering")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        sut.selectedProductType = .shoes

        let filteredProducts = sut.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 2)
        XCTAssertTrue(filteredProducts.allSatisfy { $0.product_Type.lowercased() == "shoes" })
    }

    func testFilteratedProducts_ByPriceRange() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Cheap Product", price: "25.0"),
            createMockProduct(id: 2, title: "Mid Product", price: "75.0"),
            createMockProduct(id: 3, title: "Expensive Product", price: "125.0"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded for filtering")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        sut.currentMinPrice = 50.0
        sut.currentMaxPrice = 100.0

        let filteredProducts = sut.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts[0].product_Title, "Mid Product")
    }

    func testFilteratedProducts_CombinedFilters() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Nike Shoes", type: "SHOES", price: "75.0"),
            createMockProduct(id: 2, title: "Nike Shirt", type: "T-SHIRTS", price: "25.0"),
            createMockProduct(id: 3, title: "Adidas Shoes", type: "SHOES", price: "85.0"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded for filtering")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        sut.searchedText = "Nike"
        sut.selectedProductType = .shoes
        sut.currentMinPrice = 70.0
        sut.currentMaxPrice = 80.0

        let filteredProducts = sut.filteratedProducts
        XCTAssertEqual(filteredProducts.count, 1)
        XCTAssertEqual(filteredProducts[0].product_Title, "Nike Shoes")
    }

    func testCalculatePriceRange_WithValidPrices() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Product 1", price: "10.50"),
            createMockProduct(id: 2, title: "Product 2", price: "99.99"),
            createMockProduct(id: 3, title: "Product 3", price: "55.25"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Price range calculated")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sut.minPrice, 10.50, accuracy: 0.01)
        XCTAssertEqual(sut.maxPrice, 99.99, accuracy: 0.01)
        XCTAssertEqual(sut.currentMinPrice, 10.50, accuracy: 0.01)
        XCTAssertEqual(sut.currentMaxPrice, 99.99, accuracy: 0.01)
    }

    func testCalculatePriceRange_WithInvalidPrices() {
        let mockProducts = [
            createMockProduct(id: 1, title: "Product 1", price: "invalid"),
            createMockProduct(id: 2, title: "Product 2", price: "no-price"),
        ]
        mockAllProductsUseCase.mockProducts = mockProducts

        let expectation = expectation(description: "Products loaded with invalid prices")

        sut.$productsState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadsProducts()
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sut.minPrice, 0)
        XCTAssertEqual(sut.maxPrice, 100)
        XCTAssertEqual(sut.currentMinPrice, 0)
        XCTAssertEqual(sut.currentMaxPrice, 100)
    }

    func testPublishedProperties_CanBeModified() {
        sut.searchedText = "test search"
        XCTAssertEqual(sut.searchedText, "test search")

        sut.selectedProductType = .shoes
        XCTAssertEqual(sut.selectedProductType, .shoes)

        sut.selectedCategory = .men
        XCTAssertEqual(sut.selectedCategory, .men)

        sut.currentMinPrice = 25.0
        XCTAssertEqual(sut.currentMinPrice, 25.0)

        sut.currentMaxPrice = 75.0
        XCTAssertEqual(sut.currentMaxPrice, 75.0)

        sut.showingCategorySheet = true
        XCTAssertTrue(sut.showingCategorySheet)
    }
}
