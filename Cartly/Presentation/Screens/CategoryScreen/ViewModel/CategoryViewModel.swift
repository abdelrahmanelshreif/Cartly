import Combine
import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published private(set) var productsState: ResultState<[ProductMapper]> = .loading
    @Published private(set) var cartState: ResultState<Int> = .loading
    @Published var searchedText = ""
    @Published var selectedProductType: ProductType = .all
    @Published var selectedCategory: CategoryFilter = .all
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100
    @Published var currentMinPrice: Double = 0
    @Published var currentMaxPrice: Double = 100
    @Published var showingCategorySheet = false

    private let allProductsUseCase: GetAllProductsUseCase
    private let getProductByCategoryUsecase: GetProductsForCategoryId

    private var cancellables: Set<AnyCancellable> = []
    private var allProducts: [ProductMapper] = []

    var filteratedProducts: [ProductMapper] {
        var products = allProducts

        if !searchedText.isEmpty {
            products = products.filter { product in
                product.product_Title.localizedCaseInsensitiveContains(searchedText)
            }
        }

        if selectedProductType != .all {
            products = products.filter {
                $0.product_Type.lowercased() == selectedProductType.rawValue.lowercased()
            }
        }

        products = products.filter { product in
            if let price = parsePrice(from: product.product_Price) {
                return price >= currentMinPrice && price <= currentMaxPrice
            }
            return true
        }

        return products
    }

    init(
        allProductsUseCase: GetAllProductsUseCase,
        getProductByCategoryUsecase: GetProductsForCategoryId
    ) {
        self.allProductsUseCase = allProductsUseCase
        self.getProductByCategoryUsecase = getProductByCategoryUsecase
    }

    func loadsProducts() {
        allProductsUseCase.execute()
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case let .failure(error):
                    self?.productsState = .failure(error.localizedDescription)
                }
            } receiveValue: { [weak self] products in
                self?.productsState = .success(products)
                self?.allProducts = products
                self?.calculatePriceRange()
            }
            .store(in: &cancellables)
    }

    func loadProductsByCategory(categoryId: Int64) {
        if categoryId == 0 {
            loadsProducts()
            return
        }

        getProductByCategoryUsecase.execute(for: categoryId)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case let .failure(error):
                    self?.productsState = .failure(error.localizedDescription)
                }
            } receiveValue: { [weak self] products in
                self?.productsState = .success(products)
                self?.allProducts = products
                self?.calculatePriceRange()
            }
            .store(in: &cancellables)
    }

    private func calculatePriceRange() {
        let prices = allProducts.compactMap { product -> Double? in
            return parsePrice(from: product.product_Price)
        }

        if !prices.isEmpty {
            let actualMinPrice = prices.min() ?? 0
            let actualMaxPrice = prices.max() ?? 1000
            
            minPrice = actualMinPrice
            maxPrice = actualMaxPrice
            currentMinPrice = actualMinPrice
            currentMaxPrice = actualMaxPrice
        }
    }

    private func parsePrice(from priceString: String) -> Double? {
        let cleanedString = priceString.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)

        if let price = Double(cleanedString) {
            return price
        }

        let pattern = #"\d+\.?\d*"#
        if let range = cleanedString.range(of: pattern, options: .regularExpression) {
            let numberString = String(cleanedString[range])
            return Double(numberString)
        }

        return nil
    }
}

enum ProductType: String, CaseIterable {
    case all = "ALL"
    case shoes = "SHOES"
    case snowboard = "SNOWBOARD"
    case accessories = "ACCESSORIES"
    case tshirt = "T-SHIRTS"

    var icon: String {
        switch self {
        case .all: return ""
        case .shoes: return "👟"
        case .snowboard: return "🏂"
        case .accessories: return "🎒"
        case .tshirt: return "👕"
        }
    }

    var displayName: String {
        switch self {
        case .all: return "All"
        default: return icon
        }
    }
}

enum CategoryFilter: String, CaseIterable {
    case all = "All"
    case kid = "Kid"
    case men = "Men"
    case sale = "Sale"
    case women = "Women"

    var id: Int64 {
        switch self {
        case .all: return 0
        case .kid: return 307654164663
        case .men: return 307654099127
        case .sale: return 307654197431
        case .women: return 307654131895
        }
    }
}
