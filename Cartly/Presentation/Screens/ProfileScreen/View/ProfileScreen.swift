import Combine
import SwiftUI

// MARK: - Profile Screen

struct ProfileScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared
        .resolveProfileViewModel()
    @State private var showOrderList: Bool = false
    @State private var selectedOrder: OrderEntity? = nil
    @State private var showOrderDetail: Bool = false
    @State private var showSignOutAlert: Bool = false

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
            if viewModel.currentUser != nil {
                viewModel.loadOrders()
            }
        }
        .sheet(isPresented: $showOrderList) {
            OrdersListScreen(orders: viewModel.orders) { order in
                selectedOrder = order
                showOrderDetail = true
            }
        }
        .sheet(
            item: $selectedOrder,
            onDismiss: { selectedOrder = nil }
        ) { order in
            OrderDetailScreen(order: order)
        }.alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                viewModel.signOut()
            }
        } message: {
            Text(
                "Are you sure you want to sign out? You'll need to sign in again to access your account."
            )
        }
    }
}

// MARK: - View Components

extension ProfileScreen {
    private var loggedInView: some View {
        ScrollView {
            VStack(spacing: 30) {
                ProfileHeaderView(user: viewModel.currentUser)

                if !viewModel.orders.isEmpty {
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

                        if viewModel.isLoadingOrders {
                            ProgressView()
                                .frame(height: 130)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.recentOrders) { order in
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
                    }
                } else if viewModel.isLoadingOrders {
                    VStack(spacing: 16) {
                        ProgressView("Loading orders...")
                            .frame(height: 100)
                    }
                } else {
                    EmptyOrdersView()
                }

                VStack(spacing: 0) {
                    Button(action: { router.push(Route.settings) }) {
                        ProfileMenuRowView(
                            iconName: "gearshape.fill", title: "Settings")
                    }

                    Divider().padding(.leading)

                    Button(action: {
                        router.push(Route.adresses)
                    }) {
                        ProfileMenuRowView(
                            iconName: "location.fill", title: "Addresses")
                    }

                    Divider().padding(.leading)

                    Button(action: { showSignOutAlert = true }) {
                        ProfileMenuRowView(
                            iconName: "arrow.left.circle.fill",
                            title: "Sign Out", tintColor: .red)
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
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .accentColor))
            Text("Signing out...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty Orders View

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No orders yet")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Your order history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Updated Order Card View

struct ModernOrderCardView: View {
    let order: OrderEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: orderIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(order.orderName)
                        .font(.headline)
                        .lineLimit(1)

                    Text(order.itemsSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Text(order.status.capitalized)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor)
                .clipShape(Capsule())

            Spacer()

            HStack {
                Text(order.formattedTotalPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                Text(order.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 150)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .frame(minWidth: 200)
    }

    private var orderIcon: String {
        order.isDraftOrder ? "doc.text" : "shippingbox.circle.fill"
    }

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "paid", "delivered", "completed":
            return .green
        case "shipped", "pending":
            return .orange
        case "processing", "open":
            return .purple
        case "cancelled", "refunded":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Orders List Screen

struct OrdersListScreen: View {
    let orders: [OrderEntity]
    let onOrderTapped: (OrderEntity) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredOrders: [OrderEntity] {
        if searchText.isEmpty {
            return orders
        }
        return orders.filter { order in
            order.orderName.localizedCaseInsensitiveContains(searchText)
                || order.items.contains {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredOrders) { order in
                Button {
                    onOrderTapped(order)
                    dismiss()
                } label: {
                    OrderRowView(order: order)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search orders")
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

// MARK: - Order Row View

struct OrderRowView: View {
    let order: OrderEntity

    var body: some View {
        HStack(spacing: 15) {
            Image(
                systemName: order.isDraftOrder
                    ? "doc.text.fill" : "shippingbox.fill"
            )
            .font(.title)
            .foregroundColor(.accentColor)
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.orderName)
                    .font(.headline)

                HStack {
                    Text(order.status.capitalized)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor)
                        .cornerRadius(4)

                    Text("\(order.itemsSummary)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(order.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(order.formattedTotalPrice)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "paid", "delivered", "completed":
            return .green
        case "shipped", "pending":
            return .orange
        case "processing", "open":
            return .purple
        case "cancelled", "refunded":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Order Detail Screen

struct OrderDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared
        .resolveProfileViewModel()
    @EnvironmentObject var router: AppRouter
    @State private var displayOrder: OrderEntity?

    let order: OrderEntity?
    let fromPayment: Bool

    init(order: OrderEntity, fromPayment: Bool = false) {
        self.order = order
        self.fromPayment = fromPayment
    }

    init(fromPayment: Bool = false) {
        order = nil
        self.fromPayment = fromPayment
    }

    var body: some View {
        NavigationView {
            Group {
                if let currentOrder = displayOrder ?? order {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            orderHeaderSection(for: currentOrder)
                            orderItemsSection(for: currentOrder)
                            pricingSection(for: currentOrder)
                        }
                        .padding()
                    }
                } else if viewModel.isLoadingOrders {
                    VStack {
                        ProgressView("Loading orders...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Please wait...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("No Orders Found")
                            .font(.headline)

                        Text("Unable to load order details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button("Try Again") {
                            viewModel.loadOrders()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if fromPayment {
                            router.setRoot(RootState.main)
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            if order == nil && displayOrder == nil {
                viewModel.loadOrders()
            }
        }
        .onChange(of: viewModel.orders) { _, newOrders in
            if order == nil && displayOrder == nil && !newOrders.isEmpty {
                displayOrder = newOrders.first
            }
        }
    }
}

// MARK: - Order Detail Components

extension OrderDetailScreen {
    fileprivate func orderHeaderSection(for order: OrderEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.orderName)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                statusBadge(for: order)
            }

            Text("Order #\(order.orderNumber)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(order.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    fileprivate func statusBadge(for order: OrderEntity) -> some View {
        Text(order.status.capitalized)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(for: order))
            .cornerRadius(8)
    }

    fileprivate func orderItemsSection(for order: OrderEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ITEMS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            VStack(spacing: 0) {
                ForEach(order.items) { item in
                    OrderItemRow(
                        item: item, isLast: item.id == order.items.last?.id)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }

    fileprivate func pricingSection(for order: OrderEntity) -> some View {
        VStack(spacing: 12) {
            Text("PRICING")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                pricingRow(
                    title: "Subtotal",
                    value: "\(order.totalPrice)")

                Divider()

                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(order.formattedTotalPrice)
                        .fontWeight(.bold)
                }
                .font(.headline)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }

    fileprivate func pricingRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .font(.body)
    }

    fileprivate func statusColor(for order: OrderEntity) -> Color {
        switch order.status.lowercased() {
        case "paid", "delivered", "completed":
            return .green
        case "shipped", "pending":
            return .orange
        case "processing", "open":
            return .purple
        case "cancelled", "refunded":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Order Item Row

struct OrderItemRow: View {
    let item: OrderItemEntity
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.body)
                        .fontWeight(.medium)

                    Text("Quantity: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(item.formattedTotalPrice)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .padding()

            if !isLast {
                Divider()
            }
        }
    }
}
