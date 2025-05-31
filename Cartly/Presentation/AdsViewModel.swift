//
//  AdsViewModel.swift
//  Cartly
//
//  Created by Khalid Amr on 31/05/2025.
//

import Foundation
import Combine
import UIKit
final class PriceRulesViewModel: ObservableObject {
    @Published var priceRules: [PriceRule] = []
    @Published var currentIndex: Int = 0
    @Published var showToast: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let useCase: GetPriceRulesUseCaseProtocol

    init(useCase: GetPriceRulesUseCaseProtocol) {
        self.useCase = useCase
        fetchPriceRules()
    }

    func fetchPriceRules() {
        useCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Failed to fetch price rules:", error.localizedDescription)
                }
            }, receiveValue: { [weak self] rules in
                self?.priceRules = rules
            })
            .store(in: &cancellables)
    }

    func copyCode(for index: Int) {
        let code = "\(priceRules[index].title)"
        UIPasteboard.general.string = code
        print("\(UIPasteboard.general.string ?? "")")
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
}
