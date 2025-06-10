import Foundation

// MARK: - Root JSON Response
struct SmartCollectionsResponse: Codable {
    var smartCollections: [SmartCollection]?

    enum CodingKeys: String, CodingKey {
        case smartCollections = "smart_collections"
    }
}

// MARK: - Smart Collection Model
struct SmartCollection: Codable {
    var id: Int64?
    var handle: String?
    var title: String?
    var updatedAt: String?
    var bodyHtml: String?
    var publishedAt: String?
    var sortOrder: String?
    var templateSuffix: String?
    var disjunctive: Bool?
    var rules: [Rule]?
    var publishedScope: String?
    var adminGraphqlApiId: String?
    var image: CollectionImage?

    enum CodingKeys: String, CodingKey {
        case id, handle, title, rules, image, disjunctive
        case updatedAt = "updated_at"
        case bodyHtml = "body_html"
        case publishedAt = "published_at"
        case sortOrder = "sort_order"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

// MARK: - Rule Model (Used for filtering logic in collections)
struct Rule: Codable {
    var column: String?
    var relation: String?
    var condition: String?
}

// MARK: - Image Model (Metadata for collection images)
struct CollectionImage: Codable {
    var createdAt: String?
    var alt: String?
    var width: Int?
    var height: Int?
    var src: String?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case alt, width, height, src
    }
}
