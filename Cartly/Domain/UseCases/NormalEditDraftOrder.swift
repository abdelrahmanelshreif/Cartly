//
//  NormalEditDraftOrder.swift
//  Cartly
//
//  Created by Khaled Mustafa on 17/06/2025.
//

import Combine

class NormalEditDraftOrderUseCase {
    let repository: RepositoryProtocol
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
}
