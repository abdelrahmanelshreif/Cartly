//
//  ApplePayDelegate.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import PassKit

class FakePaymentDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
    var onPaymentCompleted: (() -> Void)?
    var onPaymentCancelled: (() -> Void)?
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            print(" Apple Pay was cancelled")
            self?.onPaymentCancelled?()
        }
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print(" Apple Pay authorization successful")
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        
    }
}
