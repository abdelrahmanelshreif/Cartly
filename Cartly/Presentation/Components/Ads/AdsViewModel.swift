//
//  PriceRulesViewModel.swift
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
    @Published var state: ResultState<[PriceRule]> = .loading

    private var cancellables = Set<AnyCancellable>()
    private let useCase: FetchAllDiscountCodesUseCaseProtocol

    init(useCase: FetchAllDiscountCodesUseCaseProtocol) {
        self.useCase = useCase
    }

    func fetchPriceRules() {
        state = .loading
        useCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .failure(error.localizedDescription)
                    print("Fetch failed: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] rules in
                self?.priceRules = rules
                self?.state = .success(rules)
            }
            .store(in: &cancellables)
    }

    func copyCode(for index: Int) {
        guard !priceRules.isEmpty,
              (0..<priceRules.count).contains(index) else { return }
        
        if let code = priceRules[index].discountCodes?.first?.code {
            UIPasteboard.general.string = code
            print("Copied code: \(code)")
        } else {
            UIPasteboard.general.string = priceRules[index].title
        }

        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
}
