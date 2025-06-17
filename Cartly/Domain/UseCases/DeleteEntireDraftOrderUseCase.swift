//
//  DeleteDraftOrderUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 17/06/2025.
//

import Foundation
import Combine

struct DeleteEntireDraftOrderUseCase {
    private let repository: DeleteEntireDraftOrderUseCaseProtocol

    init(repository: DeleteEntireDraftOrderUseCaseProtocol) {
        self.repository = repository
    }

    func execute(draftOrderID: Int64) -> AnyPublisher<Bool, Error> {
        return repository.deleteEntireDraftOrder(draftOrderID: draftOrderID)
    }
}
