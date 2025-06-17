//
//  CurrencyManager.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation
import Combine
import SwiftUI

final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()

    @Published var selectedCurrency: String
    @Published var conversionRate: Double

    private var cancellables = Set<AnyCancellable>()
    private let useCase: ConvertCurrencyUseCaseProtocol

    private init(useCase: ConvertCurrencyUseCaseProtocol = ConvertCurrencyUseCase(
        repository: CurrencyRepository(service: CurrencyAPIService())
    )) {
        self.useCase = useCase
        self.selectedCurrency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        self.conversionRate = 1.0

        $selectedCurrency
            .removeDuplicates()
            .sink { [weak self] currency in
                self?.saveCurrencyToDefaults(currency)
                self?.fetchRateIfNeeded()
            }
            .store(in: &cancellables)

        fetchRateIfNeeded()
    }

    private func fetchRateIfNeeded() {
        guard selectedCurrency != "EGP" else {
            conversionRate = 1.0
            return
        }

        useCase.execute(from: "EGP", to: selectedCurrency)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] rate in
                self?.conversionRate = rate
            })
            .store(in: &cancellables)
    }

    private func saveCurrencyToDefaults(_ currency: String) {
        UserDefaults.standard.set(currency, forKey: "currency")
    }

    func convert(_ usdPrice: Double) -> Double {
        return usdPrice * conversionRate
    }

    func format(_ usdPrice: Double) -> String {
        let converted = convert(usdPrice)
        let symbol = selectedCurrency == "EGP" ? "E£" : "$"
        return "\(symbol)\(String(format: "%.2f", converted))"
    }
}

