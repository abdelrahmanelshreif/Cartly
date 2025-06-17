import Foundation
import Combine
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool
    @Published var selectedCurrency: String

    private let currencyManager = CurrencyManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.isDarkMode = DarkModeManager.shared.isDarkMode
        self.selectedCurrency = currencyManager.selectedCurrency

        setupBindings()
    }

    private func setupBindings() {
        $isDarkMode
            .removeDuplicates()
            .sink { newValue in
                DarkModeManager.shared.isDarkMode = newValue
            }
            .store(in: &cancellables)

        $selectedCurrency
            .removeDuplicates()
            .sink { [weak self] newCurrency in
                self?.currencyManager.selectedCurrency = newCurrency
            }
            .store(in: &cancellables)
    }

    func toggleDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
    }
}
