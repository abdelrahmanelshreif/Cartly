import Foundation
import Combine
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool
    @Published var selectedCurrency: String
    @Published var conversionRate: Double = 1.0
    @Published var isLoadingRate = false
    @Published var error: String?

    private let useCase: ConvertCurrencyUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(useCase: ConvertCurrencyUseCaseProtocol) {
        self.useCase = useCase
        self.isDarkMode = DarkModeManager.shared.isDarkMode
        self.selectedCurrency = CurrencyManager.shared.selectedCurrency

        setupBindings()
    }

    private func setupBindings() {
        // Dark Mode binding
        $isDarkMode
            .removeDuplicates()
            .sink { newValue in
                DarkModeManager.shared.isDarkMode = newValue
            }
            .store(in: &cancellables)

        // Currency binding
        $selectedCurrency
            .removeDuplicates()
            .sink { newCurrency in
                print(" Selected currency updated to: \(newCurrency)")
                CurrencyManager.shared.selectedCurrency = newCurrency
            }
            .store(in: &cancellables)

        // Listen to updates from CurrencyManager
        CurrencyManager.shared.$selectedCurrency
            .removeDuplicates()
            .sink { [weak self] updatedCurrency in
                guard let self else { return }
                if self.selectedCurrency != updatedCurrency {
                    self.selectedCurrency = updatedCurrency
                }
                self.loadConversionRate(for: updatedCurrency)
            }
            .store(in: &cancellables)
    }

    func loadConversionRate(for currency: String? = nil) {
        let target = currency ?? selectedCurrency
        let base = "USD"

        print(" Converting from \(base) to: \(target)")

        if target == base {
            conversionRate = 1.0
            return
        }

        isLoadingRate = true
        error = nil

        useCase.execute(from: base, to: target)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoadingRate = false
                if case let .failure(err) = result {
                    self?.error = err.localizedDescription
                }
            }, receiveValue: { [weak self] rate in
                print(" Received rate: \(rate)")
                self?.conversionRate = rate
            })
            .store(in: &cancellables)
    }

    func toggleDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
    }
}
