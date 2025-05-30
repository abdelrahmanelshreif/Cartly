//
//  BrandsView.swift
//  Cartly
//
//  Created by Khaled Mustafa on 30/05/2025.
//

import SwiftUI

struct BrandsSimpleListView: View {
    @StateObject private var viewModel: BrandsViewModel

    init(viewModel: BrandsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.brands, id: \.id) { brand in
            Text(brand.title ?? "No Title")
        }
        .onAppear {
            viewModel.fetchBrands()
        }
    }
}
