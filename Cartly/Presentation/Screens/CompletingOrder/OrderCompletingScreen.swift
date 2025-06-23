//
//  OrderCompletingScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//
import SwiftUI
import PassKit

struct OrderCompletingScreen: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    @EnvironmentObject private var router: AppRouter
    @StateObject var vm: OrderCompletingViewModel
    @StateObject var addressVM: AddressesViewModel
    @StateObject var paymentVM: PaymentViewModel
    
    @State private var isProcessingOrder = false
    @State private var showSuccessAlert = false
    @State private var showCODLimitAlert: Bool = false
    
    private let cart: CartMapper
    
    
    init(cart: CartMapper) {
        self.cart = cart
        _vm = StateObject(wrappedValue: OrderCompletingViewModel(
            cartItems: cart.itemsMapper,
            calculateSummary: CalculateOrderSummaryUseCase(),
            validatePromo: ValidatePromoCodeUseCase(
                fetchRulesUseCase: FetchAllDiscountCodesUseCase(
                    repository: DiscountCodeRepository(
                        networkService: AlamofireService(),
                        adsNetworkService: AdsNetworkService()
                    )
                )
            ),
            editDraftOrderUseCase: EditDraftOrderAtPlacingOrderUseCase(
                repository: RepositoryImpl(
                    remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                    firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
                )
            ),
            completeDraftOrderUseCase: CompleteDraftOrderUseCase(
                repository: RepositoryImpl(
                    remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                    firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
                )
            ),
            deleteDraftOrderUseCase: DeleteEntireDraftOrderUseCase(
                repository: RepositoryImpl(
                    remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()),
                    firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())
                )
            ),currencyManager: CurrencyManager.shared
            
            
        ))
        
        _addressVM = StateObject(wrappedValue: DIContainer.shared.resolveAddressViewModel())
        
        _paymentVM = StateObject(wrappedValue: PaymentViewModel())
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 8) {
//                    Text("Review & Complete Order")
//                        .font(.title2).bold()
//                        .padding(.horizontal)
//                        .padding(.top, 10)
                    
                    AddressesView(viewModel: addressVM)
                    cartPreview
                    orderSummarySection
                    PaymentView(viewModel: paymentVM, selectedPayment: $vm.selectedPayment)
                    placeOrderButton()
                }
            }
            
            if isProcessingOrder {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {}
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
        .navigationTitle("Place Order")
        .alert(isPresented: $showCODLimitAlert) {
            Alert(
                title: Text("Order Error"),
                message: Text(vm.errorMessage ?? "Unknown error."),
                dismissButton: .default(Text("OK")) {
                    isProcessingOrder = false
                }
            )
        }
        .alert("Order Completed", isPresented: $showSuccessAlert) {
            Button("Continue Shopping") {
                router.setRoot(.main)
            }
            Button("View Order Summary") {
                router.push(Route.order(true))
            }
        } message: {
            Text("Your order has been placed successfully.")
        }
        .onAppear {
            paymentVM.onPaymentCompleted = {
                vm.completeDraftOrder(withId: Int(cart.orderID)) { completeSuccess in
                    if completeSuccess {
                        vm.deleteEntireDraftOrder(withId: cart.orderID) { deleted in
                            if deleted {
                                showSuccessAlert = true
                                
                            } else {
                                showCODLimitAlert = true
                            }
                            isProcessingOrder = false
                        }
                    } else {
                        showCODLimitAlert = true
                        isProcessingOrder = false
                    }
                }
            }
            
            paymentVM.onPaymentCancelled = {
                isProcessingOrder = false
            }
        }
    }
    
    struct CartPreview: View {
        let item: ItemsMapper
        @EnvironmentObject private var currencyManager: CurrencyManager
        
        var body: some View {
            VStack {
                if let urlString = item.itemImage, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
                
                Text(item.productTitle)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(item.variantTitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("x\(item.quantity)")
                    .font(.caption2)
                
                if let priceValue = Double(item.price) {
                    Text(currencyManager.format(priceValue * Double(item.quantity)))
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    Text("Invalid Price")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    var cartPreview: some View {
        VStack(alignment: .leading) {
            Text("Your Items").font(.headline).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.getCartItems(), id: \.itemId) { item in
                        CartPreview(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var orderSummarySection: some View {
        VStack(spacing: 12) {
            Text("Order Info").font(.headline)
            summaryRow("Subtotal", vm.orderSummary.subtotal)
            
            HStack {
                TextField("Coupon Code", text: $vm.promoCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(vm.discount > 0 ? "Remove" : "Apply") {
                    vm.applyPromo()
                }
                .disabled(vm.isApplyingCoupon)
            }
            
            if let error = vm.errorMessage {
                Text(error).foregroundColor(.red).font(.caption)
            }
            
            summaryRow("Discount", -vm.discount)
            Divider()
            summaryRow("Total", vm.orderSummary.total, isBold: true)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    func summaryRow(_ label: String, _ amount: Double, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(currencyManager.format(amount))
                .fontWeight(isBold ? .bold : .regular)
        }
    }
    
    @ViewBuilder
    private func placeOrderButton() -> some View {
        Button(action: {
            isProcessingOrder = true
            addressVM.ensureDefaultAddressBeforePlacingOrder { success in
                DispatchQueue.main.async {
                    if success, let selectedAddress = addressVM.defaultAddress {
                        if vm.canCompleteOrder() {
                            vm.updateDraftOrderBeforePlacing(draftOrderID: cart.orderID, address: selectedAddress) { updateSuccess in
                                if updateSuccess {
                                    if vm.selectedPayment == .cash {
                                        vm.completeDraftOrder(withId: Int(cart.orderID)) { completeSuccess in
                                            if completeSuccess {
                                                vm.deleteEntireDraftOrder(withId: cart.orderID) { deleted in
                                                    if deleted {
                                                        showSuccessAlert = true
                                                    } else {
                                                        showCODLimitAlert = true
                                                    }
                                                    isProcessingOrder = false
                                                }
                                            } else {
                                                showCODLimitAlert = true
                                                isProcessingOrder = false
                                            }
                                        }
                                    } else if vm.selectedPayment == .applePay {
                                        paymentVM.handleCompleteOrder(total: vm.orderSummary.total)
                                    }
                                } else {
                                    showCODLimitAlert = true
                                    isProcessingOrder = false
                                }
                            }
                        }
                        else {
                            showCODLimitAlert = true
                            isProcessingOrder = false
                        }
                    } else {
                        showCODLimitAlert = true
                        isProcessingOrder = false
                    }
                }
            }
        }) {
            if paymentVM.isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Place Order")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom)
        .disabled(isProcessingOrder || paymentVM.isProcessing)
    }
}
