import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue:
            HomeViewModel(
                getBrandUseCase: GetBrandsUseCase(
                    repository: RepositoryImpl(
                        remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService())
                    )
                )
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            HomeToolbar(cartState: viewModel.cartState)
                .padding(.bottom, 12)
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 220)
                .overlay(
                    Text("Welcome to Our Store!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                )
                .padding(.horizontal)
            
            HStack {
                Text("Brands")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.blue)
                    .kerning(1.2)
                    .padding(.vertical, 4)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(.blue)
                            .offset(y: 8),
                        alignment: .bottom
                    )
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<10) { index in
                        ProductCardView(index: index)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical)
            
            // 5. Nice Tab Bar
            CustomTabBar()
                .frame(height: 70)
                .background(Color(UIColor.systemBackground).shadow(radius: 2))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
                viewModel.loadCartItemCount()
            }
    }
}

struct ProductCardView: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 140, height: 120)
                .overlay(Text("Item \(index + 1)").foregroundColor(.black))
                .cornerRadius(10)
            
            Text("Product \(index + 1)")
                .font(.headline)
                .lineLimit(1)
            
            Text("$\(index * 5 + 10)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
    }
}

struct CustomTabBar: View {
    @State private var selectedIndex = 0
    
    let icons = ["house.fill", "magnifyingglass", "cart.fill", "person.crop.circle"]
    
    var body: some View {
        HStack {
            ForEach(0..<icons.count, id: \.self) { i in
                Spacer()
                Button(action: {
                    selectedIndex = i
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: icons[i])
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(selectedIndex == i ? .blue : .gray)
                        if selectedIndex == i {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 3)
    }
}
