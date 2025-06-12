//
//  OrderCompletingViewModel.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation
import Combine
import SwiftUI

final class OrderCompletingViewModel: ObservableObject {
    // Input
    @Published var promoCode: String = ""
    @Published var selectedPayment: PaymentMethod = .cash

    // Output
    @Published private(set) var orderSummary: OrderSummary
    @Published private(set) var discount: Double = 0
    @Published private(set) var errorMessage: String?
    @Published var isApplyingCoupon = false

    private let cartItems: [CartItem]
    private let codLimitForCash: Double = 100
    private let calculateSummary: CalculateOrderSummaryUseCase
    private let validatePromo: ValidatePromoCodeUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cartItems: [CartItem],
         calculateSummary: CalculateOrderSummaryUseCase,
         validatePromo: ValidatePromoCodeUseCaseProtocol) {
        self.cartItems = cartItems
        self.calculateSummary = calculateSummary
        self.validatePromo = validatePromo
        self.orderSummary = calculateSummary.execute(for: cartItems, discount: 0, taxRate: 0.14)
    }

    func applyPromo() {
        isApplyingCoupon = true
        errorMessage = nil
        let subtotal = orderSummary.subtotal

        validatePromo.execute(code: promoCode, subtotal: subtotal, selectedPayment: selectedPayment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isApplyingCoupon = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] validated in
                guard let self = self else { return }
                self.discount = validated.discountAmount
                self.orderSummary = self.calculateSummary.execute(
                    for: self.cartItems,
                    discount: validated.discountAmount,
                    taxRate: 0.14
                )
            }
            .store(in: &cancellables)
    }

    func getCartItems() -> [CartItem] { cartItems }

    func canCompleteOrder() -> Bool {
        print("🔎 Payment method:", selectedPayment.rawValue)
           print("🔎 Order total:", orderSummary.total)
        if selectedPayment == .cash && orderSummary.total > codLimitForCash {
            errorMessage = "Cash on Delivery is not available for orders above $\(Int(codLimitForCash))."
            return false
        }
        errorMessage = nil
        return true
    }
}


