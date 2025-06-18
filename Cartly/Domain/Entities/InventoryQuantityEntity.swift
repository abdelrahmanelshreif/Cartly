//
//  InventoryQuantityEntity.swift
//  Cartly
//
//  Created by Khaled Mustafa on 17/06/2025.
//

struct InventoryQuantityEntity: Codable {
    let variantID: Int64
    let oldQuantity: Int
    let newQuantity: Int
    let ifAvailable: Bool
}

