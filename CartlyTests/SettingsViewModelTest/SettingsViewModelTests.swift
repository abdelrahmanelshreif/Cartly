//
//  SettingsViewModelTests.swift
//  CartlyTests
//
//  Created by Khalid Amr on 26/06/2025.
//

import XCTest
import Combine
@testable import Cartly

final class SettingsViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Tests

    func testConversionRateSuccess() {
        let expectedRate: Double = 30.0
        let mockUseCase = MockConvertCurrencyUseCase(result: .success(expectedRate))
        let viewModel = SettingsViewModel(useCase: mockUseCase)

        let expectation = XCTestExpectation(description: "Conversion rate fetched")
        viewModel.loadConversionRate(for: "EGP")

        viewModel.$conversionRate
            .dropFirst()
            .sink { rate in
                XCTAssertEqual(rate, expectedRate)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testConversionRateFailure() {

        let mockError = NSError(domain: "Test", code: 1, userInfo: nil)
        let mockUseCase = MockConvertCurrencyUseCase(result: .failure(mockError))
        let viewModel = SettingsViewModel(useCase: mockUseCase)

        let expectation = XCTestExpectation(description: "Conversion rate failure handled")
        viewModel.loadConversionRate(for: "EGP")

        viewModel.$error
            .dropFirst()
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, mockError.localizedDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleDarkModeUpdatesSharedManager() {

        let mockUseCase = MockConvertCurrencyUseCase(result: .success(1.0))
        let viewModel = SettingsViewModel(useCase: mockUseCase)

        viewModel.toggleDarkMode(true)

        XCTAssertTrue(DarkModeManager.shared.isDarkMode)
    }

    func testSelectedCurrencyUpdatesSharedManager() {

        let mockUseCase = MockConvertCurrencyUseCase(result: .success(1.0))
        let viewModel = SettingsViewModel(useCase: mockUseCase)

        viewModel.selectedCurrency = "EGP"

        XCTAssertEqual(CurrencyManager.shared.selectedCurrency, "EGP")
    }
}
