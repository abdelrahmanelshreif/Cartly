import Combine
//
//  ProfileViewModel.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 9/6/25.
//
import Foundation

class ProfileViewModel: ObservableObject {
    private let signOutUseCase: SignOutUseCaseProtocol
    private let getUserSession: GetCurrentUserInfoUseCaseProtocol
    private let getOrdersUseCase: GetCustomerOrderUseCaseProtocol

    @Published var loading = false
    @Published var isLoadingOrders = false
    @Published var didSignOut = false
    @Published var currentUser: UserEntity?
    @Published var orders: [OrderEntity] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    var recentOrders: [OrderEntity] {
        Array(orders.prefix(5))
    }

    init(
        signOutUseCase: SignOutUseCaseProtocol,
        getUserSession: GetCurrentUserInfoUseCaseProtocol,
        getOrdersUseCase: GetCustomerOrderUseCaseProtocol
    ) {
        self.signOutUseCase = signOutUseCase
        self.getUserSession = getUserSession
        self.getOrdersUseCase = getOrdersUseCase

        checkUserSession()
    }

    func checkUserSession() {
        currentUser = getUserSession.execute()

        guard let user = currentUser else {
            print("No user session found.")
            didSignOut = true
            return
        }

        if user.sessionStatus == false {
            print("User session is inactive.")
            didSignOut = true
        }
    }

    func loadOrders() {
        guard let userId = currentUser?.id else {
            print("DEBUG: loadOrders: currentUser or userId is nil. Cannot load orders.")
            return
        }
        print("DEBUG: loadOrders: Attempting to load orders for userId: \(userId)")

        isLoadingOrders = true
        errorMessage = nil

        getOrdersUseCase.execute(customerId: Int64(userId) ?? 0)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingOrders = false
                    switch completion {
                    case .finished:
                        print("DEBUG: loadOrders: Orders loading finished successfully.")
                    case .failure(let error):
                        self?.errorMessage = "Failed to load orders: \(error)"
                        self?.orders = []
                        print("DEBUG: loadOrders: Failed with error: \(error)")
                    }
                },
                receiveValue: { [weak self] orders in
                    print("DEBUG: loadOrders: Received \(orders.count) orders.")
                    self?.orders = orders
                }	
            )
            .store(in: &cancellables)
    }
    

    func signOut() {
        loading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            _ = self?.signOutUseCase.execute()
            self?.currentUser = self?.getUserSession.execute()
            self?.orders = []
            self?.loading = false
            self?.didSignOut = true
        }
    }
}
