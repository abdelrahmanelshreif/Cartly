import Foundation

/// A mapper struct responsible for mapping API response models to simplified local entities representations used in the app.
struct DataMapper {
    /// Maps an array of `SmartCollection` objects to an array of `BrandMapper`.
    ///
    /// - Parameter collections: The raw `SmartCollection` data from the API.
    /// - Returns: An array of `BrandMapper` with selected brand data.
    static func createBrands(from collections: [SmartCollection]) -> [BrandMapper] {
        return collections.map { BrandMapper(from: $0) }
    }

    /// Maps an array of `Product` objects to an array of `ProductMapper`.
    ///
    /// - Parameter products: The raw `Product` data from the API.
    /// - Returns: An array of `ProductMapper` with selected product data.
    static func createProducts(from products: [Product]) -> [ProductMapper] {
        return products.map { ProductMapper(from: $0) }
    }

    /// Maps an array of `CustomCollection` objects to an array of `CategoryMapper`.
    ///
    /// - Parameter categories: The raw `CustomCollection` data from the API.
    /// - Returns: An array of `CategoryMapper` with selected category data.
    static func createCategories(from categories: [CustomCollection]) -> [CategoryMapper] {
        return categories.map { CategoryMapper(from: $0) }
    }
}
