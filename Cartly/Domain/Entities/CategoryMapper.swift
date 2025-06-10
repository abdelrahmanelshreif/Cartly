import Foundation

// MARK: - Category Mapper Model
struct CategoryMapper {
    var collection_id: Int64
    var handle: String
    var title: String

    init(from collection: CustomCollection) {
        self.collection_id = collection.id ?? 0
        self.handle = collection.handle ?? ""
        self.title = collection.title ?? ""
    }
}

