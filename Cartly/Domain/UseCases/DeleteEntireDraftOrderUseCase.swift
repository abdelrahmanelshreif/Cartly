//
//  DeleteDraftOrderUseCase.swift
//  Cartly
//
//  Created by Khalid Amr on 17/06/2025.
//

import Foundation
import Combine

final class DeleteDraftOrderUseCase: DeleteDraftOrderUseCaseProtocol {
    private let repository: RepositoryImpl

    init(repository: RepositoryImpl) {
        self.repository = repository
    }

    func execute(draftOrderID: Int64) -> AnyPublisher<Bool, Error> {
        let function: (Int64) -> AnyPublisher<Bool, Error> = repository.deleteExistingDraftOrder
        return function(draftOrderID)
    }
}
