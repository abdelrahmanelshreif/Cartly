
struct CartMapper: Codable {
    let orderID: Int64
    let orderStatus: String
    let hasAddress: Bool
    let itemsMapper: [ItemsMapper]

    init(draft: DraftOrder) {
        self.orderID = draft.id ?? -1
        self.orderStatus = draft.status ?? "unknown"
        self.hasAddress = (draft.customer?.addresses?.isEmpty == false)
        self.itemsMapper = draft.lineItems?.compactMap { ItemsMapper(lineItem: $0) } ?? []
    }
}

struct ItemsMapper: Codable {
    var itemId: Int64
    var variantId: Int64
    var productId: Int64
    var productTitle: String
    var variantTitle: String
    var quantity: Int
    var price: String

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



#if false
struct CartMapper : Codable {
    let orderID: Int64
    let orderStatus: String
    let hasAddress: Bool
    let itemsMapper: [ItemsMapper]
    
    init(draft: DraftOrder){
        self.orderID = draft.id!
        self.orderStatus = draft.status!
        self.hasAddress = draft.customer?.addresses?.count ?? 0 > 0
        self.itemsMapper = draft.lineItems!.map(ItemsMapper.init)
    }
}

struct ItemsMapper : Codable {
    var itemId: Int64
    var variantId: Int64
    var productId: Int64
    var productTitle: String
    var variantTitle: String
    var quantity: Int
    var price: String
    
    init(lineItem: LineItem){
        self.itemId = lineItem.id!
        self.variantId = lineItem.variantId!
        self.productId = lineItem.productId!
        self.productTitle = lineItem.title!
        self.variantTitle = lineItem.variantTitle!
        self.quantity = lineItem.quantity!
        self.price = lineItem.price!
    }
}
#endif
