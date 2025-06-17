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
    @Published var conversionRate: Double = 1.0
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let useCase: ConvertCurrencyUseCaseProtocol
    
    private init(useCase: ConvertCurrencyUseCaseProtocol = ConvertCurrencyUseCase(
        repository: CurrencyRepository(service: CurrencyAPIService())
    )) {
        self.useCase = useCase
        self.selectedCurrency = UserDefaults.standard.string(forKey: "currency") ?? "EGP" 
        
        $selectedCurrency
            .removeDuplicates()
            .sink { [weak self] currency in
                self?.saveCurrencyToDefaults(currency)
                self?.fetchConversionRate()
            }
            .store(in: &cancellables)
        
        fetchConversionRate()
    }
    
    func fetchConversionRate() {
        guard selectedCurrency != "EGP" else {
            conversionRate = 1.0
            return
        }
        
        isLoading = true
        cancellables.removeAll()
        
        useCase.execute(from: "EGP", to: selectedCurrency)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Currency conversion error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] rate in
                print("Fetched new conversion rate: \(rate)")
                self?.conversionRate = rate
            })
            .store(in: &cancellables)
    }
    
    private func saveCurrencyToDefaults(_ currency: String) {
        UserDefaults.standard.set(currency, forKey: "currency")
    }
    
    func convert(_ egpPrice: Double) -> Double {
        return selectedCurrency == "EGP" ? egpPrice : egpPrice * conversionRate
    }
    
    func format(_ egpPrice: Double) -> String {
        let converted = convert(egpPrice)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency
        
        if selectedCurrency == "EGP" {
            formatter.currencySymbol = "E£"
        } else if selectedCurrency == "USD" {
            formatter.currencySymbol = "$"
        }
        
        return formatter.string(from: NSNumber(value: converted)) ?? "\(converted)"
    }
}
