//
//  ApplePayDelegate.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import PassKit

class FakePaymentDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
    var onPaymentCompleted: (() -> Void)?
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            print("✅ Fake Apple Pay completed")
            self.onPaymentCompleted?() 
        }
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
}
