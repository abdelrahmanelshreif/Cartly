//
//  CartScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 08/06/2025.
//

import SwiftUI

struct CartScreen: View {
    @State private var cartItems: [CartItem] = CartItem.sampleData
    @State private var total: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($cartItems) { $item in
                            CartItemView(item: $item, onDelete: {
                                withAnimation {
                                    cartItems.removeAll { $0.id == item.id }
                                }
                            })
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("$\(cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding([.horizontal, .top])
                
                Button(action: {
                    // Checkout action
                }) {
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Cart")
        }
    }
}

struct CartItemView: View {
    @Binding var item: CartItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(item.imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text("\(item.size) / \(item.color)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                
                HStack {
                    Button(action: {
                        if item.quantity > 1 { item.quantity -= 1 }
                    }) {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(item.quantity)")
                        .padding(.horizontal, 8)
                    
                    Button(action: {
                        item.quantity += 1
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                }
                .font(.title3)
                .padding(.top, 4)
            }
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}
struct CartItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let size: String
    let color: String
    let price: Double
    var quantity: Int
    
    static let sampleData: [CartItem] = [
        .init(imageName: "backpack", title: "Adidas Classic Backpack", size: "OS", color: "Black", price: 70, quantity: 1),
        .init(imageName: "stan_smith", title: "Adidas Kid's Stan Smith", size: "1", color: "White", price: 90, quantity: 4),
        .init(imageName: "boots", title: "Dr. Martens 1460Z Cherry", size: "3", color: "Red", price: 249, quantity: 1)
    ]
}
#Preview {
    CartScreen()
}
