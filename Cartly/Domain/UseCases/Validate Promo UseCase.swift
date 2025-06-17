//
//  Validate Promo UseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 11/06/2025.
//

import Foundation
import Combine
protocol ValidatePromoCodeUseCaseProtocol {
    func execute(code: String, subtotal: Double, selectedPayment: PaymentMethod) -> AnyPublisher<ValidatedDiscount, PromoError>
}

final class ValidatePromoCodeUseCase: ValidatePromoCodeUseCaseProtocol {
    private let fetchRulesUseCase: FetchAllDiscountCodesUseCaseProtocol

    init(fetchRulesUseCase: FetchAllDiscountCodesUseCaseProtocol) {
        self.fetchRulesUseCase = fetchRulesUseCase
    }

    func execute(code: String, subtotal: Double, selectedPayment: PaymentMethod) -> AnyPublisher<ValidatedDiscount, PromoError> {
        fetchRulesUseCase.execute()
            .tryMap { rules in
                guard let rule = rules.first(where: { $0.discountCodes?.contains(where: { $0.code.uppercased() == code.uppercased() }) == true }),
                      let discountCode = rule.discountCodes?.first(where: { $0.code.uppercased() == code.uppercased() })
                else { throw PromoError.codeNotFound }

                if let limit = rule.usageLimit, discountCode.usageCount >= limit {
                    throw PromoError.exceededUsageLimit
                }

                if let minStr = rule.prerequisiteSubtotalRange?.greaterThanOrEqualTo,
                   let minVal = Double(minStr), subtotal < minVal {
                    throw PromoError.insufficientSubtotal(minRequired: minVal)
                }

                let tempDiscount = self.calculateDiscountAmount(rule: rule, subtotal: subtotal)

                return ValidatedDiscount(
                    code: discountCode.code,
                    discountAmount: tempDiscount,
                    priceRuleId: rule.id,
                    discountId: discountCode.id,
                    value: rule.value,
                    value_type: rule.valueType
                    
                    
                )
            }
            .mapError { $0 as? PromoError ?? .unknown }
            .eraseToAnyPublisher()
    }

    private func calculateDiscountAmount(rule: PriceRule, subtotal: Double) -> Double {
        let rawValue = Double(rule.value) ?? 0
        switch rule.valueType {
        case "percentage":
            return subtotal * abs(rawValue) / 100
        case "fixed_amount":
            return abs(rawValue)
        default:
            return 0
        }
    }
}
