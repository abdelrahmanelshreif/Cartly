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
    
    private let cartItems: [ItemsMapper]
    private let codLimitForCash: Double = 100
    private let calculateSummary: CalculateOrderSummaryUseCase
    private let validatePromo: ValidatePromoCodeUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var appliedcoupoun = AppliedDiscount()
    private let editDraftOrderUseCase: EditDraftOrderAtPlacingOrderUseCaseProtocol
    private let completeDraftOrderUseCase: CompleteDraftOrderUseCase
    private let deleteDraftOrderUseCase: DeleteEntireDraftOrderUseCase


    
    init(cartItems: [ItemsMapper],
         calculateSummary: CalculateOrderSummaryUseCase,
         validatePromo: ValidatePromoCodeUseCaseProtocol,
         editDraftOrderUseCase:EditDraftOrderAtPlacingOrderUseCaseProtocol,
         completeDraftOrderUseCase: CompleteDraftOrderUseCase,
         deleteDraftOrderUseCase: DeleteEntireDraftOrderUseCase

) {
        self.cartItems = cartItems
        self.calculateSummary = calculateSummary
        self.validatePromo = validatePromo
        self.orderSummary = calculateSummary.execute(for: cartItems, discount: 0)
        self.editDraftOrderUseCase = editDraftOrderUseCase
        self.completeDraftOrderUseCase = completeDraftOrderUseCase
        self.deleteDraftOrderUseCase = deleteDraftOrderUseCase


    }
    
    func applyPromo() {
        if discount > 0 {
            discount = 0
            orderSummary = calculateSummary.execute(for: cartItems, discount: 0)
            promoCode = ""
            errorMessage = nil
            appliedcoupoun = AppliedDiscount()
            return
        }
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
                self.appliedcoupoun=mapValidatedCoupounToAppliedCoupoun(validateed: validated)
                self.orderSummary = self.calculateSummary.execute(
                    for: self.cartItems,
                    discount: validated.discountAmount

                )
            }
            .store(in: &cancellables)
    }
    
    func getCartItems() -> [ItemsMapper] { cartItems }
    
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
    func updateDraftOrderwithCoupounandAddress(draftOrderID:Int64,address:Address)->DraftOrder{
        var draftorder = DraftOrder()
        draftorder.id = draftOrderID
        print("the id is \(String(describing: draftorder.id))")
        draftorder.shippingAddress = mapCustomerAddressToShopifyAddress(address)
        draftorder.appliedDiscount = self.appliedcoupoun
        return draftorder
        
    }
    func updateDraftOrderBeforePlacing(draftOrderID: Int64, address: Address, completion: @escaping (Bool) -> Void) {
        let updatedDraftOrder = updateDraftOrderwithCoupounandAddress(draftOrderID: draftOrderID, address: address)
        
        editDraftOrderUseCase.execute(updatedDraftOrder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .failure(let error):
                    self?.errorMessage = "Failed to update draft order: \(error.localizedDescription)"
                    completion(false)
                case .finished:
                    self?.appliedcoupoun = AppliedDiscount()
                    break
                }
            } receiveValue: { _ in
                completion(true)
            }
            .store(in: &cancellables)
    }
    func completeDraftOrder(withId id: Int, completion: @escaping (Bool) -> Void) {
        completeDraftOrderUseCase.execute(draftOrderId: id)
            .receive(on: DispatchQueue.main)
            .sink { completionStatus in
                if case .failure(let error) = completionStatus {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            } receiveValue: {
                completion(true)
            }
            .store(in: &cancellables)
    }
    func deleteEntireDraftOrder(withId id: Int64, completion: @escaping (Bool) -> Void) {
        deleteDraftOrderUseCase.execute(draftOrderID: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            } receiveValue: { wasDeleted in
                completion(wasDeleted)
            }
            .store(in: &cancellables)
    }

    

    
}



