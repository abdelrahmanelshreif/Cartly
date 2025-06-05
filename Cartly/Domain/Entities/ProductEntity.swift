//
//  ProductEntity.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//


struct ProductInformationEntity {
    let id: Int64
    let name: String
    let description: String
    let vendor: String
    let images: [ProductInfromationImageEntity]
    let price: Double
    let originalPrice: Double
    let availableSizes: [String]
    let availableColors: [String]
    let variants: [ProductInformationVariantEntity]
    let rating: Double
    let reviewCount: Int
}

struct ProductInfromationImageEntity {
    let url: String
    let alt: String
}

struct ProductInformationVariantEntity{
    let id: Int64
    let title: String
    let price: Double
    let size: String
    let color: String
    let inventoryQuantity: Int
    let isAvailable: Bool
}

