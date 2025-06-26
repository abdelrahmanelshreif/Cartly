//
//  OrderCompletingViewModelTests.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//

import XCTest
import Combine
@testable import Cartly

final class OrderCompletingViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    private var sampleItems: [ItemsMapper] {
        [
            ItemsMapper(
                itemId: 101,
                variantId: 1001,
                productId: 5001,
                productTitle: "Test T-Shirt",
                variantTitle: "Large",
                quantity: 2,
                price: "25.0",
                itemImage: "https://example.com/tshirt.png"
            ),
            ItemsMapper(
                itemId: 102,
                variantId: 1002,
                productId: 5002,
                productTitle: "Test Mug",
                variantTitle: "White",
                quantity: 1,
                price: "10.0",
                itemImage: "https://example.com/mug.png"
            )
        ]
    }

    func test_applyPromo_success() {
        let validatedDiscount = ValidatedDiscount(code: "SAVE10", discountAmount: 10.0, priceRuleId: 1, discountId: 2)
        let mockValidatePromo = MockValidatePromoCodeUseCase(result: .success(validatedDiscount))
        let calculateSummary = CalculateOrderSummaryUseCase()

        let viewModel = OrderCompletingViewModel(
            cartItems: sampleItems,
            calculateSummary: calculateSummary,
            validatePromo: mockValidatePromo
        )
        viewModel.promoCode = "SAVE10"
        viewModel.selectedPayment = .cash

        let expectation = expectation(description: "Discount applied")

        viewModel.$orderSummary
            .dropFirst()
            .sink { summary in
                XCTAssertEqual(summary.discount, 10.0)
                XCTAssertNil(viewModel.errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.applyPromo()

        wait(for: [expectation], timeout: 1.0)
    }




    func test_applyPromo_failure_codeNotFound() {
        let mockValidatePromo = MockValidatePromoCodeUseCase(result: .failure(.codeNotFound))
        let calculateSummary = CalculateOrderSummaryUseCase()

        let viewModel = OrderCompletingViewModel(
            cartItems: sampleItems,
            calculateSummary: calculateSummary,
            validatePromo: mockValidatePromo
        )
        viewModel.promoCode = "INVALID"
        viewModel.selectedPayment = .cash

        let expectation = expectation(description: "Promo failed")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(viewModel.errorMessage, PromoError.codeNotFound.localizedDescription)
            expectation.fulfill()
        }

        viewModel.applyPromo()

        wait(for: [expectation], timeout: 1.0)
    }


    func test_canCompleteOrder_cashUnderLimit() {
        let mockValidatePromo = MockValidatePromoCodeUseCase(result: .failure(.codeNotFound))
        let calculateSummary = CalculateOrderSummaryUseCase()
        let viewModel = OrderCompletingViewModel(
            cartItems: sampleItems, // total = (2 * 25) + (1 * 10) = 60
            calculateSummary: calculateSummary,
            validatePromo: mockValidatePromo
        )

        viewModel.selectedPayment = .cash

        let canComplete = viewModel.canCompleteOrder()

        XCTAssertTrue(canComplete)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_canCompleteOrder_cashOverLimit() {
        let expensiveItems = [
            ItemsMapper(
                itemId: 201,
                variantId: 3001,
                productId: 7001,
                productTitle: "MacBook Pro",
                variantTitle: "16-inch",
                quantity: 1,
                price: "150.0",
                itemImage: "https://example.com/macbook.png"
            )
        ]

        let mockValidatePromo = MockValidatePromoCodeUseCase(result: .failure(.codeNotFound))
        let calculateSummary = CalculateOrderSummaryUseCase()
        let viewModel = OrderCompletingViewModel(
            cartItems: expensiveItems,
            calculateSummary: calculateSummary,
            validatePromo: mockValidatePromo
        )

        viewModel.selectedPayment = PaymentMethod.cash

        let canComplete = viewModel.canCompleteOrder()

        XCTAssertFalse(canComplete)
        XCTAssertEqual(viewModel.errorMessage, "Cash on Delivery is not available for orders above $100.")
    }
}

