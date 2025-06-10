//
//  Teeeeessssst.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

/*
 import SwiftUI
 struct HomeScreen: View {
     @StateObject private var viewModel: HomeViewModel
     @State private var selectedBrandId: Int64?

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
         NavigationStack {
             VStack(spacing: 0) {
                 HomeToolbar(cartState: viewModel.cartState)
                 Ads()
                 Spacer()
                 SectionHeader(headerText: "Brands")
                     .padding(.horizontal)
                     .padding(.bottom,  4)
                 Spacer()
                 Group {
                     switch viewModel.brandState {
                     case .loading:
                         ProgressView()
                     case .success(let brands):
                         BrandSectionBody(brands: brands) { brandId in
                             selectedBrandId = brandId
                         }
                     case .failure(let error):
                         Text(error)
                     }
                 }
                 Spacer()
             }
             .onAppear {
                 viewModel.loadBrands()
                 viewModel.loadCartItemCount()
             }
             .navigationDestination(isPresented: Binding<Bool>(
                 get: { selectedBrandId != nil },
                 set: { if !$0 { selectedBrandId = nil } }
             )) {
                 if let brandId = selectedBrandId {
                     ProductScreen(brandId: brandId)
                 }
             }
         }
     }
 }

 */
