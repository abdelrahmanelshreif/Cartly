//
//  MockValidatePromoCodeUseCase.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//
import Foundation
import Combine
@testable import Cartly

final class MockValidatePromoCodeUseCase: ValidatePromoCodeUseCaseProtocol {
    var result: Result<ValidatedDiscount, PromoError>

    init(result: Result<ValidatedDiscount, PromoError>) {
        self.result = result
    }

    func execute(code: String, subtotal: Double, selectedPayment: PaymentMethod) -> AnyPublisher<ValidatedDiscount, PromoError> {
        result.publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
