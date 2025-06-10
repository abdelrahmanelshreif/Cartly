import Foundation

// MARK: - Root JSON Response for Custom Collections
struct CustomCollectionsResponse: Codable {
    var customCollections: [CustomCollection]?

    enum CodingKeys: String, CodingKey {
        case customCollections = "custom_collections"
    }
}

// MARK: - Custom Collection Model
struct CustomCollection: Codable, Identifiable {
    var id: Int64?
    var handle: String?
    var title: String?
    var updatedAt: String?
    var bodyHtml: String?
    var publishedAt: String?
    var sortOrder: String?
    var templateSuffix: String?
    var publishedScope: String?
    var adminGraphqlApiId: String?
    var image: CollectionImage? /// Same struct in BrandResponse File

    enum CodingKeys: String, CodingKey {
        case id, handle, title, image
        case updatedAt = "updated_at"
        case bodyHtml = "body_html"
        case publishedAt = "published_at"
        case sortOrder = "sort_order"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}
