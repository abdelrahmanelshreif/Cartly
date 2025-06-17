func createLineItemFromCartEntity(cart: CartEntity) -> LineItem {
    return LineItem(
        variantId: cart.variantId,
        productId: cart.productId,
        quantity: cart.quantity
    )
}
func mapCustomerAddressToShopifyAddress(_ address: Address) -> ShopifyAddress {
    return ShopifyAddress(
        firstName: address.firstName,
        lastName: address.lastName,
        address1: address.address1,
        address2: address.address2,
        phone: address.phone,
        city: address.city,
        province: address.province,
        country: address.country,
        zip: address.zip
    )
}
/// when post request require for add new draft order for customer
func MapCartToDraftOrderRequestDic(cart: CartEntity) -> [String: Any] {
    return [
        "draft_order": [
            "email": cart.email,
            "fulfillment_status": "fulfilled",
            "send_receipt": true,
            "send_fulfillment_receipt": true,
            "line_items": [
                [
                    "product_id" : cart.productId,
                    "variant_id": cart.variantId,
                    "quantity": cart.quantity
                ]
            ]
        ]
    ]
}




func mapDraftOrderToDict(_ draftOrder: DraftOrder) -> [String: Any] {
    var dict: [String: Any] = [:]
    var _: [String: Any] = [:]
    
    dict["id"] = draftOrder.id
    dict["note"] = draftOrder.note
    dict["email"] = draftOrder.email
    dict["taxes_included"] = draftOrder.taxesIncluded
    dict["currency"] = draftOrder.currency
    dict["invoice_sent_at"] = draftOrder.invoiceSentAt
    dict["created_at"] = draftOrder.createdAt
    dict["updated_at"] = draftOrder.updatedAt
    dict["tax_exempt"] = draftOrder.taxExempt
    dict["completed_at"] = draftOrder.completedAt
    dict["name"] = draftOrder.name
    dict["allow_discount_codes_in_checkout?"] = draftOrder.allowDiscountCodesInCheckout
    dict["b2b?"] = draftOrder.b2b
    dict["status"] = draftOrder.status
    dict["api_client_id"] = draftOrder.apiClientId
    dict["shipping_address"] = draftOrder.shippingAddress
    dict["billing_address"] = draftOrder.billingAddress
    dict["invoice_url"] = draftOrder.invoiceUrl
    dict["created_on_api_version_handle"] = draftOrder.createdOnApiVersionHandle
    dict["order_id"] = draftOrder.orderId
    dict["shipping_line"] = draftOrder.shippingLine
    dict["tags"] = draftOrder.tags
    dict["note_attributes"] = draftOrder.noteAttributes
    dict["total_price"] = draftOrder.totalPrice
    dict["subtotal_price"] = draftOrder.subtotalPrice
    dict["total_tax"] = draftOrder.totalTax
    dict["payment_terms"] = draftOrder.paymentTerms
    dict["admin_graphql_api_id"] = draftOrder.adminGraphqlApiId
    
    if let customer = draftOrder.customer {
        dict["customer"] = mapCustomerToDict(customer)
    }
    
    if let appliedDiscount = draftOrder.appliedDiscount {
        dict["applied_discount"] = mapAppliedDiscountToDict(appliedDiscount)
    }
    if let shippingAddress = draftOrder.shippingAddress {
        dict["shipping_address"] = mapShopifyAddressToDict(shippingAddress)
    }
    
    if let lineItems = draftOrder.lineItems {
        dict["line_items"] = lineItems.map { mapLineItemToDict($0) }
    }
    
    if let taxLines = draftOrder.taxLines {
        dict["tax_lines"] = taxLines.map { mapTaxLineToDict($0) }
    }
    
    return ["draft_order": dict]
}

func mapLineItemToDict(_ item: LineItem) -> [String: Any] {
    return [
        "id": item.id as Any,
        "variant_id": item.variantId as Any,
        "product_id": item.productId as Any,
        "title": item.title as Any,
        "variant_title": item.variantTitle as Any,
        "sku": item.sku as Any,
        "vendor": item.vendor as Any,
        "quantity": item.quantity as Any,
        "requires_shipping": item.requiresShipping as Any,
        "taxable": item.taxable as Any,
        "gift_card": item.giftCard as Any,
        "fulfillment_service": item.fulfillmentService as Any,
        "grams": item.grams as Any,
        "name": item.name as Any,
        "properties": item.properties as Any,
        "custom": item.custom as Any,
        "price": item.price as Any,
        "tax_lines": item.taxLines?.map { mapTaxLineToDict($0) } as Any,
        "applied_discount": item.appliedDiscount.map { mapAppliedDiscountToDict($0) } as Any
    ]
}

func mapAppliedDiscountToDict(_ discount: AppliedDiscount) -> [String: Any] {
    
    let value = Double(discount.value ?? "") ?? 0.0
        let amount = Double(discount.amount ?? "") ?? 0.0

        return [
            "description": discount.description ?? "",
            "value": String(format: "%.2f", abs(value)),
            "value_type": discount.valueType ?? "percentage",
            "amount": String(format: "%.2f", abs(amount))
        ]
}
func mapShopifyAddressToDict(_ address: ShopifyAddress) -> [String: Any] {
    dump(address)
    
    return [
        "first_name": address.firstName ?? "",
        "last_name": address.lastName ?? "",
        "address1": address.address1 ?? "",
        "address2": address.address2 ?? "",
        "phone": address.phone ?? "",
        "city": address.city ?? "",
        "province": address.province ?? "",
        "country": address.country ?? "",
        "zip": address.zip ?? ""
    ]
}



func mapTaxLineToDict(_ taxLine: TaxLine) -> [String: Any] {
    return [:]
}

func mapCustomerToDict(_ customer: Customer) -> [String: Any] {
    return [:]
}
func mapValidatedCoupounToAppliedCoupoun (validateed : ValidatedDiscount) -> AppliedDiscount {
    var appliedDiscount = AppliedDiscount()
    appliedDiscount.description = validateed.code
    appliedDiscount.amount=String(validateed.discountAmount)
    appliedDiscount.value=validateed.value
    appliedDiscount.valueType=validateed.value_type
    return appliedDiscount
}
