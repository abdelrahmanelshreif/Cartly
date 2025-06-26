import Foundation

// MARK: - Brand Mapper Model
struct BrandMapper: Identifiable, Equatable {
    var id: Int64 { brand_ID }
    var brand_ID: Int64
    var brand_handle: String
    var brand_title: String
    var brand_image: String

    init(from smartCollection: SmartCollection) {
        brand_ID = smartCollection.id ?? 0
        brand_handle = smartCollection.handle ?? ""
        brand_title = smartCollection.title ?? ""
        brand_image = smartCollection.image?.src ?? ""
    }
}
