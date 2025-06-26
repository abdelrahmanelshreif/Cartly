//
//  AdsViewModelTest.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//

import XCTest
import Combine
@testable import Cartly

final class PriceRulesViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_fetchPriceRules_success() {
        let discountCode = DiscountCode(id: 1, code: "SAVE10", priceRuleId: 101, usageCount: 0)
        let priceRule = PriceRule(
            id: 101,
            title: "10% OFF",
            valueType: "percentage",
            value: "-10.0",
            prerequisiteSubtotalRange: nil,
            usageLimit: nil,
            discountCodes: [discountCode],
            adImageUrl: "https://example.com/ad1.png",
            prerequisiteToEntitlementQuantityRatio: nil,
            prerequisiteToEntitlementPurchase: nil
        )
        let mockUseCase = MockFetchAllDiscountCodesUseCase(result: .success([priceRule]))
        let viewModel = PriceRulesViewModel(useCase: mockUseCase)

        let expectation = expectation(description: "Price rules loaded successfully")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let rules) = state {
                    XCTAssertEqual(rules.count, 1)
                    XCTAssertEqual(rules.first?.id, 101)
                    XCTAssertEqual(rules.first?.discountCodes?.first?.code, "SAVE10")
                    XCTAssertEqual(rules.first?.adImageUrl, "https://example.com/ad1.png")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchPriceRules()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchPriceRules_failure() {
        let mockError = URLError(.notConnectedToInternet)
        let mockUseCase = MockFetchAllDiscountCodesUseCase(result: .failure(mockError))
        let viewModel = PriceRulesViewModel(useCase: mockUseCase)

        let expectation = expectation(description: "Price rules load failed")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let message) = state {
                    XCTAssertFalse(message.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchPriceRules()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_copyCode_copiesToPasteboard() {
        let discountCode = DiscountCode(id: 2, code: "FREESHIP", priceRuleId: 102, usageCount: 0)
        let priceRule = PriceRule(
            id: 102,
            title: "Free Shipping",
            valueType: "fixed_amount",
            value: "-5.0",
            prerequisiteSubtotalRange: nil,
            usageLimit: nil,
            discountCodes: [discountCode],
            adImageUrl: nil,
            prerequisiteToEntitlementQuantityRatio: nil,
            prerequisiteToEntitlementPurchase: nil
        )
        let mockUseCase = MockFetchAllDiscountCodesUseCase(result: .success([priceRule]))
        let viewModel = PriceRulesViewModel(useCase: mockUseCase)

        let loadExpectation = expectation(description: "Loaded rules")
        viewModel.$priceRules
            .dropFirst()
            .sink { rules in
                if !rules.isEmpty {
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchPriceRules()
        wait(for: [loadExpectation], timeout: 1.0)
        viewModel.copyCode(for: 0)

        XCTAssertEqual(UIPasteboard.general.string, "FREESHIP")
        XCTAssertTrue(viewModel.showToast)
    }
}
