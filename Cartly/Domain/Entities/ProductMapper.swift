import Foundation

// MARK: - Product Mapper Model
struct ProductMapper: Identifiable {
    var id: AnyHashable  // Allow Int64 or UUID
    var product_ID: Int64?
    var product_Title: String
    var product_Type: String
    var product_Vendor: String
    var product_Image: String
    var product_Price: String

    init(from product: Product) {
        if let validID = product.id {
            id = validID
            product_ID = validID
        } else {
            id = UUID()
            product_ID = nil
        }
        product_Title = product.title ?? "no-title"
        product_Type = product.productType ?? "no-type"
        product_Vendor = product.vendor ?? "no-vendor"
        product_Image = product.image?.src ?? "no-image"
        product_Price = product.variants?[0].price ?? "no-price"
    }
}
