//
//  CartlyApp.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 25/5/25.
//

import Combine
import FirebaseCore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
@main
struct CartlyApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            #if true
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            #endif
            #if false
            OrderCompletingScreen(
                    vm: OrderCompletingViewModel(
                        cartItems: CartItem.sampleData,
                        calculateSummary: CalculateOrderSummaryUseCase(),
                        validatePromo: ValidatePromoCodeUseCase(
                            fetchRulesUseCase: FetchAllDiscountCodesUseCase(
                                repository: DiscountCodeRepository(
                                    networkService: AlamofireService(),
                                    adsNetworkService: AdsNetworkService()
                                )
                            )
                        )
                    ),
                    addressVM: AddressesViewModel(
                        fetchAddressesUseCase: FetchCustomerAddressesUseCase(
                            repository: CustomerAddressRepository(networkService: AlamofireService())
                        ),
                        addAddressUseCase: AddCustomerAddressUseCase(
                            repository: CustomerAddressRepository(networkService: AlamofireService())
                        ),
                        setDefaultAddressUseCase: SetDefaultCustomerAddressUseCase(
                            repository: CustomerAddressRepository(networkService: AlamofireService())
                        ),
                        deleteAddressUseCase: DeleteCustomerAddressUseCase(
                            repository: CustomerAddressRepository(networkService: AlamofireService())
                        ),
                        editAddressUseCase: EditCustomerAddressUseCase(
                            repository: CustomerAddressRepository(networkService: AlamofireService())
                        )
                    ),
                    paymentVM: PaymentViewModel()
                )
            #endif
        }
    }
}
