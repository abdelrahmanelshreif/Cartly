//
//  BrandsViewModel.swift
//  Cartly
//
//  Created by Khaled Mustafa on 30/05/2025.
//

import Foundation
import Combine

final class BrandsViewModel: ObservableObject {
    @Published var brands: [SmartCollection] = []
    @Published var errorMessage: String?

    private let getBrandsUseCase: GetBrandsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getBrandsUseCase: GetBrandsUseCase) {
        self.getBrandsUseCase = getBrandsUseCase
    }

    func fetchBrands() {
        getBrandsUseCase.execute()
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.brands = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }
}
