//
//  ProfileScreen.swift
//  Cartly
//
//  Created by Khaled Mustafa on 04/06/2025.
//
import Combine
import SwiftUI
import SwiftUI

struct Order: Identifiable {
    let id: UUID
    let orderID: String
    let status: String
    let price: Double
}

struct ProfileScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared.resolveProfileViewModel()
    
    private let dummyOrders: [Order] = [
        Order(id: UUID(), orderID: "ORD-1001", status: "Delivered", price: 299.99),
        Order(id: UUID(), orderID: "ORD-1002", status: "Shipped", price: 89.50),
        Order(id: UUID(), orderID: "ORD-1003", status: "Processing", price: 45.00)
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            Group {
                if viewModel.currentUser?.sessionStatus == true {
                    ScrollView {
                        VStack(spacing: 0) {
                            ProfileHeaderView(user: viewModel.currentUser)
                                .padding(20)
                            
                            VStack(spacing: 16) {
                                ProfileMenuSection(title: "My Account") {
                                    
                            
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Orders")
                                                .font(.headline)
                                            Spacer()
                                            Button("See More") {
//                                                router.push(.orders)
                                            }
                                            .font(.subheadline)
                                        }
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 12) {
                                                ForEach(dummyOrders) { order in
                                                    OrderCardView(order: order)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                
                                }
                                
                                Button(action: {
                                    viewModel.signOut()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.circle.fill")
                                            .font(.title3)
                                        Text(
                                            viewModel.loading
                                                ? "Signing Out..." : "Sign Out"
                                        )
                                        .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .disabled(viewModel.loading)
                            }
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                router.push(Route.settings)
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                } else if viewModel.loading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .blue))
                        Text("Signing out...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LoggedOutView {
                        router.setRoot(.authentication)
                    }
                }
            }
        }
        .onAppear {
            viewModel.checkUserSession()
        }
    }
}

struct OrderCardView: View {
    let order: Order
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order ID: \(order.orderID)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("Status: \(order.status)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "Price: $%.2f", order.price))
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2, y: 2)
        .frame(width: 160)
    }
}
