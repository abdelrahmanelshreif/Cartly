//
// ProfileScreen.swift
// Cartly
//
// Created by Khaled Mustafa on 04/06/2025.
//
import SwiftUI
import Combine

// MARK: - Data Models

struct Order: Identifiable {
    let id: UUID
    let orderID: String
    let status: String
    let price: Double
}

// MARK: - Profile Screen
struct ProfileScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared.resolveProfileViewModel()

    private let dummyOrders: [Order] = [
        Order(id: UUID(), orderID: "ORD-1001", status: "Delivered", price: 299.99),
        Order(id: UUID(), orderID: "ORD-1002", status: "Shipped", price: 89.50),
        Order(id: UUID(), orderID: "ORD-1003", status: "Processing", price: 45.00)
    ]
    @State private var showOrderList: Bool = false
    @State private var selectedOrder: Order? = nil
    @State private var showOrderDetail: Bool = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            Group {
                if viewModel.currentUser?.sessionStatus == true {
                    loggedInView
                } else if viewModel.loading {
                    loadingView
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
        .sheet(isPresented: $showOrderList) {
            OrdersListScreen(orders: dummyOrders) { order in
                selectedOrder = order
                showOrderDetail = true
            }
        }
        .sheet(isPresented: $showOrderDetail, onDismiss: { selectedOrder = nil }) {
            if let selectedOrder = selectedOrder {
                OrderDetailScreen(order: selectedOrder)
            }
        }
    }
}

// MARK: - View Components
extension ProfileScreen {
    
    private var loggedInView: some View {
        ScrollView {
            VStack(spacing: 30) {
                ProfileHeaderView(user: viewModel.currentUser)

                VStack(spacing: 16) {
                    HStack {
                        Text("RECENT ORDERS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("SEE ALL") { showOrderList = true }
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(dummyOrders) { order in
                                Button {
                                    selectedOrder = order
                                    showOrderDetail = true
                                } label: {
                                    ModernOrderCardView(order: order)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(spacing: 0) {
                    Button(action: { router.push(Route.settings) }) {
                        ProfileMenuRowView(iconName: "gearshape.fill", title: "Settings")
                    }
                    
                    Divider().padding(.leading)
                    
                    Button(action: { viewModel.signOut() }) {
                        ProfileMenuRowView(iconName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    .disabled(viewModel.loading)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
            Text("Signing out...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Reusable Child Views

/// A reusable view for rows in a settings or profile list.
struct ProfileMenuRowView: View {
    let iconName: String
    let title: String
    var tintColor: Color = .primary

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(tintColor)
                .frame(width: 25)
            
            Text(title)
                .font(.body)
                .foregroundColor(tintColor)
            
            Spacer()
            
            if tintColor != .red {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}


struct ModernOrderCardView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "shippingbox.circle.fill")
                    .font(.title2)
                    .foregroundColor(statusColor(for: order.status))
                
                Text(order.orderID)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Text(order.status)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor(for: order.status))
                .clipShape(Capsule())

            Spacer()

            Text(String(format: "$%.2f", order.price))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(width: 170, height: 130)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Delivered": return .green
        case "Shipped": return .orange
        case "Processing": return .purple
        default: return .gray
        }
    }
}

// MARK: - Sheet Views (Orders List & Detail)

struct OrdersListScreen: View {
    let orders: [Order]
    let onOrderTapped: (Order) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(orders) { order in
                Button {
                    onOrderTapped(order)
                    dismiss()
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "shippingbox.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.orderID).font(.headline)
                            Text("Status: \(order.status)").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", order.price)).font(.headline).fontWeight(.semibold).foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .navigationTitle("All Orders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct OrderDetailScreen: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Order ID: \(order.orderID)").font(.title2)
                Text("Status: \(order.status)")
                Text(String(format: "Price: $%.2f", order.price))
                    .font(.title3)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding()
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
