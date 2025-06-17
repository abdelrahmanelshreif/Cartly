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

final class PaymentViewModel: NSObject, ObservableObject, PKPaymentAuthorizationControllerDelegate {
    @Published var selectedMethod: PaymentMethod? = .cash
    @Published var isProcessing = false
    
    var onPaymentCompleted: (() -> Void)?
    var onPaymentCancelled: (() -> Void)?
    
    private var paymentController: PKPaymentAuthorizationController?
    private var paymentCompletion: ((Bool) -> Void)?
    
    func handleCompleteOrder() {
        guard let method = selectedMethod else { return }
        isProcessing = true
        
        if method == .applePay {
            presentApplePaySheet()
        } else {
            simulateCashPayment()
        }
    }
    
    private func simulateCashPayment() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isProcessing = false
            print(" Order completed with Cash on Delivery")
            self?.onPaymentCompleted?()
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
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        self.paymentController = controller
        
        controller.present { [weak self] success in
            if !success {
                print(" Failed to present Apple Pay sheet")
                self?.isProcessing = false
            }
        }
    }
    
    // MARK: - PKPaymentAuthorizationControllerDelegate
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            DispatchQueue.main.async {
                self?.isProcessing = false
                print(" Apple Pay was cancelled")
                self?.onPaymentCancelled?()
            }
        }
    }
    
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print(" Apple Pay authorization successful")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            self?.isProcessing = false
            self?.onPaymentCompleted?()
        }
    }
}

enum PaymentMethod: String {
    case cash = "Cash on Delivery"
    case applePay = "Apple Pay"
}
