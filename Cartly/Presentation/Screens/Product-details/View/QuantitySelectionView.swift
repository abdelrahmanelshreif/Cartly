//
//  QuantitySelectionView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct QuantitySelectionView: View {
    @Binding var quantity: Int
    var maxQuantity: Int = 99
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quantity")
                .font(.headline)
            
            HStack {
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(quantity > 1 ? .blue : .gray)
                }
                .disabled(quantity <= 1)
                
                Text("\(quantity)")
                    .font(.body)
                    .frame(minWidth: 40)
                
                Button(action: {
                    if quantity < maxQuantity {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(quantity < maxQuantity ? .blue : .gray)
                }
                .disabled(quantity >= maxQuantity)
                
                Spacer()
            }
        }
    }
}
