import Foundation

/// Root model representing the whole JSON structure
struct ProductListResponse: Codable {
    let products: [Product]
}

///// The root object of the API response containing the product data.
 struct ProductResponse: Codable {
    var product: Product?
 }

/// Represents a product in the Shopify store, including details, variants, options, and images.
struct Product: Codable {
    var id: Int64?
    var title: String?
    var bodyHtml: String?
    var vendor: String?
    var productType: String?
    var createdAt: String?
    var handle: String?
    var updatedAt: String?
    var publishedAt: String?
    var templateSuffix: String?
    var publishedScope: String?
    var tags: String?
    var status: String?
    var adminGraphqlApiId: String?
    var variants: [Variant]?
    var options: [Option]?
    var images: [ProductImage]?
    var image: ProductImage?

    enum CodingKeys: String, CodingKey {
        case id, title, vendor, handle, tags, status, variants, options, images, image
        case bodyHtml = "body_html"
        case productType = "product_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

/// Represents a specific variation of a product, such as different sizes or colors.
struct Variant: Codable {
    var id: Int64?
    var productId: Int64?
    var title: String?
    var price: String?
    var position: Int?
    var inventoryPolicy: String?
    var compareAtPrice: String?
    var option1: String?
    var option2: String?
    var option3: String?
    var createdAt: String?
    var updatedAt: String?
    var taxable: Bool?
    var barcode: String?
    var fulfillmentService: String?
    var grams: Int?
    var inventoryManagement: String?
    var requiresShipping: Bool?
    var sku: String?
    var weight: Double?
    var weightUnit: String?
    var inventoryItemId: Int64?
    var inventoryQuantity: Int?
    var oldInventoryQuantity: Int?
    var adminGraphqlApiId: String?
    var imageId: Int64?

    enum CodingKeys: String, CodingKey {
        case id, title, price, position, option1, option2, option3, taxable, barcode, sku, weight
        case productId = "product_id"
        case inventoryPolicy = "inventory_policy"
        case compareAtPrice = "compare_at_price"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fulfillmentService = "fulfillment_service"
        case grams
        case inventoryManagement = "inventory_management"
        case requiresShipping = "requires_shipping"
        case weightUnit = "weight_unit"
        case inventoryItemId = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
        case oldInventoryQuantity = "old_inventory_quantity"
        case adminGraphqlApiId = "admin_graphql_api_id"
        case imageId = "image_id"
    }
}

/// Represents an option available for a product, such as "Size" or "Color", along with its possible values.
struct Option: Codable {
    var id: Int64?
    var productId: Int64?
    var name: String?
    var position: Int?
    var values: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, position, values
        case productId = "product_id"
    }
}

/// Represents an image associated with a product or a variant, including dimensions and source URL.
struct ProductImage: Codable {
    var id: Int64?
    var alt: String?
    var position: Int?
    var productId: Int64?
    var createdAt: String?
    var updatedAt: String?
    var adminGraphqlApiId: String?
    var width: Int?
    var height: Int?
    var src: String?
    var variantIds: [Int64]?

    enum CodingKeys: String, CodingKey {
        case id, alt, position, width, height, src
        case productId = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case adminGraphqlApiId = "admin_graphql_api_id"
        case variantIds = "variant_ids"
    }
}
