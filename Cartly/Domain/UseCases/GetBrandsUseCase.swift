//
//  GetBrandsUseCase.swift
//  Cartly
//
//  Created by Khaled Mustafa on 30/05/2025.
//

import Combine

final class GetBrandsUseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<Result<[SmartCollection]?, Error>, Never> {
            return repository.getBrands()
                .map { Result.success($0) }
                .catch { error in
                    Just(Result.failure(error))
                }
                .eraseToAnyPublisher()
        }
}
