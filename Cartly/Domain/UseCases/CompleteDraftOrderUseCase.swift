//
//  CompleteDraftOrderUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 17/06/2025.
//

import Foundation
import Combine

final class CompleteDraftOrderUseCase {
    private let repository: DraftOrderRepositoryProtocol

    init(repository: DraftOrderRepositoryProtocol) {
        self.repository = repository
    }

    func execute(draftOrderId: Int) -> AnyPublisher<Void, Error> {
        return repository.completeDraftOrder(withId: draftOrderId)
    }
}
