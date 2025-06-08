//
//  SearchScreen.swift
//  Cartly
//
//  Created by Khaled Mustafa on 08/06/2025.
//

import SwiftUI

struct SearchScreen: View {
    @StateObject var viewModel: SearchViewModel
    @EnvironmentObject var router: AppRouter

    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel(allProductsUseCase: GetAllProductsUseCase(repository: RepositoryImpl(remoteDataSource: RemoteDataSourceImpl(networkService: AlamofireService()), firebaseRemoteDataSource: FirebaseDataSource(firebaseServices: FirebaseServices())))))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    SearchBar(text: $viewModel.searchedText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    PriceRangeSlider(
                        minPrice: $viewModel.currentMinPrice,
                        maxPrice: $viewModel.currentMaxPrice,
                        priceRange: viewModel.minPrice ... viewModel.maxPrice
                    )
                    .padding(.horizontal, 16)
                    Group {
                        switch viewModel.productsState {
                        case .loading:
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading products...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)

                        case let .failure(error):
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)

                                VStack(spacing: 8) {
                                    Text("Something went wrong")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }

                                Button(action: {
                                    viewModel.loadsProducts()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Try Again")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)

                        case .success:
                            if viewModel.filteratedProducts.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)

                                    VStack(spacing: 8) {
                                        Text("No products found")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)

                                        Text("Try adjusting your search or filters")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                LazyVStack(spacing: 0) {
                                    HStack {
                                        Text("\(viewModel.filteratedProducts.count) products found")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible(), spacing: 16),
                                            GridItem(.flexible(), spacing: 16),
                                        ],
                                        spacing: 24
                                    ) {
                                        ForEach(viewModel.filteratedProducts) { product in
                                            ProductCardView(product: product)
                                                .transition(.scale.combined(with: .opacity))
                                                
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteratedProducts.count)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
            .refreshable {
                viewModel.loadsProducts()
            }
        }
        .navigationTitle("Search in All Products")
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            viewModel.loadsProducts()
            viewModel.loadCartItemCount()
        }
        .background(Color(.systemGroupedBackground))
    }
}
