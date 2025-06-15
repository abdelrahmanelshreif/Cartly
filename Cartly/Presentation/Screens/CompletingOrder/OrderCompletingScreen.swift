//
//  OrderCompletingScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import SwiftUI

import SwiftUI

struct OrderCompletingScreen: View {
    @StateObject var vm: OrderCompletingViewModel
    @StateObject var addressVM: AddressesViewModel
    @StateObject var paymentVM: PaymentViewModel
    
    @State private var waitingForAddressToPlaceOrder = false
    @State private var showSuccessAlert = false
    @State private var showCODLimitAlert: Bool = false
    
    private let cart: CartMapper
    
    init(cart: CartMapper) {
        self.cart = cart
        print("\(cart) in OrderCompletingScreen!!!!!!!!")
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
            )
        ))
        
        _addressVM = StateObject(wrappedValue: AddressesViewModel(
            fetchAddressesUseCase: FetchCustomerAddressesUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            addAddressUseCase: AddCustomerAddressUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            setDefaultAddressUseCase: SetDefaultCustomerAddressUseCase(
                repository: CustomerAddressRepository(
                    networkService: AlamofireService()
                )
            ),
            deleteAddressUseCase: DeleteCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService())),
            editAddressUseCase: EditCustomerAddressUseCase(repository: CustomerAddressRepository(networkService: AlamofireService()))
        ))
        
        _paymentVM = StateObject(wrappedValue: PaymentViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Review & Complete Order")
                    .font(.title2).bold()
                    .padding(.horizontal)
                
                AddressesView(viewModel: addressVM)
                cartPreview
                orderSummarySection
                PaymentView(viewModel: paymentVM, selectedPayment: $vm.selectedPayment)
                
                Button(action: {
                    addressVM.ensureDefaultAddressBeforePlacingOrder { success in
                        DispatchQueue.main.async {
                            if success {
                                if vm.canCompleteOrder() {
                                    paymentVM.handleCompleteOrder()
                                } else {
                                    showCODLimitAlert = true
                                }
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
                .disabled(paymentVM.isProcessing)

            }
        }
        .navigationTitle("Payment")
        .alert(isPresented: $showCODLimitAlert) {
            Alert(
                title: Text("Order Error"),
                message: Text(vm.errorMessage ?? "Unknown error."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Order Completed", isPresented: $showSuccessAlert) {
            Button("Continue Shopping") { }
            Button("View Order Summary") { }
        } message: {
            Text("Your order has been placed successfully.")
        }
        .onAppear {
            paymentVM.onPaymentCompleted = {
                showSuccessAlert = true
            }
        }
    }
    
    struct CartPreview: View {
        let item: ItemsMapper
        
        var body: some View {
            VStack {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                
                Text(item.productTitle)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(item.variantTitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("x\(item.quantity)")
                    .font(.caption2)
                
                if let priceValue = Double(item.price) {
                    Text("$\(priceValue * Double(item.quantity), specifier: "%.2f")")
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
            Text("$\(amount, specifier: "%.2f")")
                .fontWeight(isBold ? .bold : .regular)
        }
    }
}
