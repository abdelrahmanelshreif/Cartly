import Combine
import SwiftUI

protocol SearchViewModelProtocol: ObservableObject {
    var productsState: ResultState<[ProductMapper]> { get }
    var cartState: ResultState<Int> { get }
    var searchedText: String { get set }
    var minPrice: Double { get }
    var maxPrice: Double { get }
    var currentMinPrice: Double { get set }
    var currentMaxPrice: Double { get set }
    var filteratedProducts: [ProductMapper] { get }

    func loadsProducts()
}

class SearchViewModel: SearchViewModelProtocol {
    @Published private(set) var productsState: ResultState<[ProductMapper]> = .loading
    @Published private(set) var cartState: ResultState<Int> = .loading
    @Published var searchedText = ""
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100
    @Published var currentMinPrice: Double = 0
    @Published var currentMaxPrice: Double = 100

    private let allProductsUseCase: GetAllProductsUseCase

    private var cancellables: Set<AnyCancellable> = []
    private var allProducts: [ProductMapper] = []

    var filteratedProducts: [ProductMapper] {
        var products = allProducts

        if !searchedText.isEmpty {
            products = products.filter { product in
                product.product_Title.localizedCaseInsensitiveContains(searchedText)
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
        allProductsUseCase: GetAllProductsUseCase
    ) {
        self.allProductsUseCase = allProductsUseCase
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

    private func calculatePriceRange() {
        let prices = allProducts.compactMap { product -> Double? in
            parsePrice(from: product.product_Price)
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
