import Combine
import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var selectedCurrency: String

    private let currencyManager = CurrencyManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        selectedCurrency = currencyManager.selectedCurrency
        setupBindings()
    }

    private func setupBindings() {
        $selectedCurrency
            .removeDuplicates()
            .sink { [weak self] newCurrency in
                self?.currencyManager.selectedCurrency = newCurrency
            }
            .store(in: &cancellables)
    }
}
