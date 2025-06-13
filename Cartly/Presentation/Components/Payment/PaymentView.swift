//
//  PaymentView.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import SwiftUI

struct PaymentView: View {
    @StateObject private var viewModel: PaymentViewModel
    @Binding var selectedPayment: PaymentMethod

    init(viewModel: PaymentViewModel, selectedPayment: Binding<PaymentMethod>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedPayment = selectedPayment
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Payment Method")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(spacing: 12) {
                paymentOption(.cash, title: "Cash on Delivery", icon: "banknote.fill")
                paymentOption(.applePay, title: "Apple Pay", icon: "applelogo")
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }

    private func paymentOption(_ method: PaymentMethod, title: String, icon: String) -> some View {
        Button(action: {
            viewModel.selectedMethod = method
            selectedPayment = method
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(method == .applePay ? .black : .green)
                    .frame(width: 24)

                Text(title).font(.body)
                Spacer()
                Image(systemName: viewModel.selectedMethod == method ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    
    PaymentView(viewModel: PaymentViewModel(), selectedPayment: .constant(.cash))
    
}
