import Combine
//
//  ProductDetailsViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 2/6/25.
//
import Foundation

class ProductDetailsViewModel: ObservableObject {
    @Published var resultState:
        ResultStateViewLayer<ProductInformationEntity>? = nil
    
   
    private let getProductUseCase: GetProductDetailsUseCaseProtocol

    init(getProductUseCase: GetProductDetailsUseCaseProtocol) {
        self.getProductUseCase = getProductUseCase
    }

    private var cancellables = Set<AnyCancellable>()

    func getProduct(for product: Int64) {
        getProductUseCase.execute(productId: product)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .success(let productResponse):
                    guard let product = productResponse else { return }
                    let mappedProduct =
                        ProducInformationtMapper.mapShopifyProductToProductView(
                            product)
                    print("doneeeeeeeee")
                    self?.resultState = .success(mappedProduct)
                case .failure(_):
                    print("faiiilllll")
                    self?.resultState = .failure(
                        AppError.failedFetchingDataFromNetwork)
                }
            }
            .store(in: &cancellables)
    }

}
