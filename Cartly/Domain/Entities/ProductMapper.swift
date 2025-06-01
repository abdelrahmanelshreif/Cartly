import Foundation

// MARK: - Product Mapper Model
struct ProductMapper {
    var product_ID: Int64
    var product_Title: String
    var product_Type: String
    var product_Vendor: String
    var product_Image: String

    init(from product: Product) {
        product_ID = product.id ?? -1
        product_Title = product.title ?? ""
        product_Type = product.productType ?? ""
        product_Vendor = product.vendor ?? ""
        product_Image = product.image?.src ?? ""
    }
}
