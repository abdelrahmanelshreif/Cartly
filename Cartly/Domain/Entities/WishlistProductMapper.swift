//
//  WishlistProductMapper.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 7/6/25.
//

extension WishlistProduct {
    static func from(entity: ProductInformationEntity) -> WishlistProduct {
        return WishlistProduct(
            id: nil,
            productId: String(entity.id),
            title: entity.name,
            bodyHtml: entity.description,
            vendor: entity.vendor,
            productType: "N/A", 
            status: entity.variants.first?.isAvailable == true ? "active" : "inactive",
            image: entity.images.first?.url,
            price: entity.price
        )
    }
}
