//
//  EditDraftOrderAtPlacingOrderUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 15/06/2025.
//

import Foundation
import Combine
protocol EditDraftOrderAtPlacingOrderUseCaseProtocol {
    func execute(_ draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error>
}
final class EditDraftOrderAtPlacingOrderUseCase: EditDraftOrderAtPlacingOrderUseCaseProtocol {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error> {
        return repository.editDraftOrderAtPlacingOrder(draftOrder)
    }
}
