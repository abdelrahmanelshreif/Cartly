//
//  TestView.swift
//  Cartly
//
//  Created by Khaled Mustafa on 29/05/2025.
//

import SwiftUI

struct TestView: View {
    
    @ObservedObject private var viewModel = HomeViewModel()
    
    var body: some View {

        
        List(viewModel.categories){ category in
            Text(category.title ?? "no data")
        }.onAppear {
            viewModel.getCategories()
        }
    }
}
