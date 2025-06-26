//
//  OrderEntity.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 17/6/25.
//

import Foundation

// MARK: - UI Entity Models
struct OrderEntity: Identifiable , Equatable {
    static func == (lhs: OrderEntity, rhs: OrderEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let orderName: String
    let totalPrice: String
    let currency: String
    let date: Date
    let items: [OrderItemEntity]
    let isDraftOrder: Bool
    let status: String
}

struct OrderItemEntity: Identifiable {
    let id: String
    let title: String
    let quantity: Int
    let price: String
}


// MARK: - Order Mapper
protocol OrderMapperProtocol {
    func mapOrders(from response: CustomerOrdersResponse) -> [OrderEntity]
    func mapDraftOrders(from response: DraftOrdersResponse) -> [OrderEntity]
}

class OrderMapper: OrderMapperProtocol {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    // MARK: - Map Regular Orders
    func mapOrders(from response: CustomerOrdersResponse) -> [OrderEntity] {
        guard let orders = response.orders else { return [] }
        return orders.compactMap { mapOrder(from: $0) }
    }
    
    private func mapOrder(from order: Order) -> OrderEntity? {
        guard let id = order.id else { return nil }
        
        let orderName = order.name ?? "Order #\(order.orderNumber ?? 0)"
        
        let totalPrice = order.totalPrice ?? order.currentTotalPrice ?? "0.00"
        let currency = order.currency ?? order.presentmentCurrency ?? "USD"
        
        let dateString = order.createdAt ?? order.updatedAt ?? ""
        let date = dateFormatter.date(from: dateString) ?? Date()
        
        let items = mapLineItems(from: order.lineItems)
        
        let status = order.financialStatus ?? "pending"
        
        return OrderEntity(
            id: String(id),
            orderName: orderName,
            totalPrice: totalPrice,
            currency: currency,
            date: date,
            items: items,
            isDraftOrder: false,
            status: status
        )
    }
    
    // MARK: - Map Draft Orders
    func mapDraftOrders(from response: DraftOrdersResponse) -> [OrderEntity] {
        guard let draftOrders = response.draftOrders else { return [] }
        return draftOrders.compactMap { mapDraftOrder(from: $0) }
    }
    
    private func mapDraftOrder(from draftOrder: DraftOrder) -> OrderEntity? {
        guard let id = draftOrder.id else { return nil }
        
        let orderName = draftOrder.name ?? "Draft Order #\(id)"
        
        let totalPrice = draftOrder.totalPrice ?? "0.00"
        let currency = draftOrder.currency ?? "USD"
        
        let dateString = draftOrder.createdAt ?? draftOrder.updatedAt ?? ""
        let date = dateFormatter.date(from: dateString) ?? Date()
        
        let items = mapLineItems(from: draftOrder.lineItems)
        
        let status = draftOrder.status ?? "open"
        
        return OrderEntity(
            id: String(id),
            orderName: orderName,
            totalPrice: totalPrice,
            currency: currency,
            date: date,
            items: items,
            isDraftOrder: true,
            status: status
        )
    }
    
    // MARK: - Map Line Items
    private func mapLineItems(from lineItems: [LineItem]?) -> [OrderItemEntity] {
        guard let lineItems = lineItems else { return [] }
        
        return lineItems.compactMap { item in
            guard let id = item.id ?? item.variantId ?? item.productId else { return nil }
            
            let title = item.title ?? item.name ?? "Unknown Product"
            let quantity = item.quantity ?? 1
            let price = item.price ?? "0.00"
            
            return OrderItemEntity(
                id: String(id),
                title: title,
                quantity: quantity,
                price: price
            )
        }
    }
}


// MARK: - OrderEntity Extensions
extension OrderEntity {
    var formattedTotalPrice: String {
        return "\(currency) \(totalPrice)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var itemsCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    var itemsSummary: String {
        let count = itemsCount
        return count == 1 ? "1 item" : "\(count) items"
    }
    
    var orderNumber: Int {
        if let number = orderName.components(separatedBy: "#").last,
           let orderNum = Int(number.trimmingCharacters(in: .whitespaces)) {
            return orderNum
        }
        return Int(id) ?? 0
    }
}

// MARK: - OrderItemEntity Extensions
extension OrderItemEntity {
    var formattedPrice: String {
        return price
    }
    
    var formattedTotalPrice: String {
        if let priceDecimal = Decimal(string: price) {
            let total = priceDecimal * Decimal(quantity)
            return String(format: "%.2f", NSDecimalNumber(decimal: total).doubleValue)
        }
        return price
    }
}
