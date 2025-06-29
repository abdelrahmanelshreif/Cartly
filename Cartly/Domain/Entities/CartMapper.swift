
struct CartMapper: Codable, Hashable {
    var orderID: Int64
    var orderStatus: String
    var hasAddress: Bool
    var itemsMapper: [ItemsMapper]

    init(draft: DraftOrder) {
        orderID = draft.id ?? -1
        orderStatus = draft.status ?? "unknown"
        hasAddress = (draft.customer?.addresses?.isEmpty == false)
        itemsMapper = draft.lineItems?.compactMap { ItemsMapper(lineItem: $0) } ?? []
    }
}

struct ItemsMapper: Codable, Hashable {
    var itemId: Int64
    var variantId: Int64
    var productId: Int64
    var productTitle: String
    var variantTitle: String
    var quantity: Int
    var price: String
    var itemImage: String?
    var currentInStock: Int?

    init?(lineItem: LineItem) {
        guard
            let itemId = lineItem.id,
            let variantId = lineItem.variantId,
            let productId = lineItem.productId,
            let productTitle = lineItem.title,
            let variantTitle = lineItem.variantTitle,
            let quantity = lineItem.quantity,
            let price = lineItem.price
        else {
            return nil
        }
        self.itemId = itemId
        self.variantId = variantId
        self.productId = productId
        self.productTitle = productTitle
        self.variantTitle = variantTitle
        self.quantity = quantity
        self.price = price
    }
}
   
struct UpdateQuantityEntity: Codable {
    let orderID: Int64
    let itemID: Int64
    let Quantity: Int
    let variantID: Int64
}
