//
//  PaymentViewModel.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation
import PassKit
import Combine

protocol PaymentViewModelProtocol: ObservableObject {
    var selectedMethod: PaymentMethod? { get set }
    var isProcessing: Bool { get }
    
    func handleCompleteOrder()
}

final class PaymentViewModel: NSObject, ObservableObject {
    @Published var selectedMethod: PaymentMethod? = .cash
    @Published var isProcessing = false
    
    var onPaymentCompleted: (() -> Void)?
    private var paymentDelegate: FakePaymentDelegate?
    
    func handleCompleteOrder() {
        guard let method = selectedMethod else { return }
        
        if method == .applePay {
            presentApplePaySheet()
        } else {
            simulateCashPayment()
        }
    }
    
    private func simulateCashPayment() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isProcessing = false
            print("✅ Order completed with Cash on Delivery")
            self.onPaymentCompleted?()
        }
    }
    
    private func presentApplePaySheet() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.fake.cartly"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Cartly Order", amount: NSDecimalNumber(string: "49.99")),
            PKPaymentSummaryItem(label: "Cartly Inc.", amount: NSDecimalNumber(string: "49.99"))
        ]
        
        let delegate = FakePaymentDelegate()
        delegate.onPaymentCompleted = { [weak self] in
            self?.onPaymentCompleted?()
        }
        paymentDelegate = delegate
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = paymentDelegate
        controller.present { success in
            if !success {
                print("❌ Failed to present Apple Pay sheet")
            }
        }
    }
}
enum PaymentMethod: String {
    case cash = "Cash on Delivery"
    case applePay = "Apple Pay"
}
