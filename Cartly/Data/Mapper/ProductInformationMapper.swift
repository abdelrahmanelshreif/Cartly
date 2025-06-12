//
//  ProductInformationMapper.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//

class ProducInformationtMapper {
    
    static func mapShopifyProductToProductView(_ shopifyProduct: Product) -> ProductInformationEntity {
        
        let variants = shopifyProduct.variants ?? []
        let options = shopifyProduct.options ?? []
        let images = shopifyProduct.images ?? []
        
        let sizes = extractSizes(from: variants, options: options)
        let colors = extractColors(from: variants, options: options)
        let mappedImages = images.map { mapImage($0) }
        let mappedVariants = variants.map { mapVariant($0, options: options) }
        let price = getPrice(from: variants)
        
        return ProductInformationEntity(
            id: shopifyProduct.id ?? 0,
            name: shopifyProduct.title ?? "NA",
            description: shopifyProduct.bodyHtml ?? "NA",
            vendor: shopifyProduct.vendor ?? "NA",
            images: mappedImages,
            price: price,
            originalPrice: price,
            availableSizes: sizes,
            availableColors: colors,
            variants: mappedVariants,
            rating: 4.5,
            reviewCount: 0  
        )
    }

    private static func getPrice(from variants: [Variant]) -> Double {
        if variants.isEmpty {
            return 0.0
        }
        
        let prices = variants.compactMap { Double($0.price ?? "NA") }
        return prices.min() ?? 0.0
    }

    private static func mapVariant(_ shopifyVariant: Variant, options: [Option]) -> ProductInformationVariantEntity {
        return ProductInformationVariantEntity(
            id: shopifyVariant.id ?? 0,
            title: shopifyVariant.title ?? "NA",
            price: Double(shopifyVariant.price ?? "NA") ?? 0.0,
            size: shopifyVariant.option1 ?? "NA",
            color: shopifyVariant.option2 ?? "NA",
            inventoryQuantity: shopifyVariant.inventoryQuantity ?? 0,
            isAvailable: shopifyVariant.inventoryQuantity ?? 0 > 0
        )
    }
    
    private static func mapImage(_ shopifyImage: ProductImage) -> ProductInfromationImageEntity {
        return ProductInfromationImageEntity(
            url: shopifyImage.src ?? "NA",
            alt: shopifyImage.alt ?? "NA"
        )
    }

    private static func extractColors(from variants: [Variant], options: [Option]) -> [String] {
        guard options.contains(where: { $0.name?.lowercased() == "color" }) else {
            return []
        }
        
        let availableColors = variants.compactMap { $0.option2 }
        return Array(Set(availableColors)).sorted()
    }

    private static func extractSizes(from variants: [Variant], options: [Option]) -> [String] {
        guard options.contains(where: { $0.name?.lowercased() == "size" }) else {
            return []
        }
        
        let availableSizes = variants.compactMap { $0.option1 }
        return Array(Set(availableSizes)).sorted()
    }
}
