//
//  QuantitySelectionView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct QuantitySelectionView: View {
    @Binding var quantity: Int
    
    var body: some View {
        HStack {
            Text("Quantity")
                .font(.headline)
            
            Spacer()
            
            HStack {
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.blue)
                }
                .disabled(quantity <= 1)
                
                Text("\(quantity)")
                    .font(.body)
                    .padding(.horizontal, 16)
                
                Button(action: {
                    quantity += 1
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
