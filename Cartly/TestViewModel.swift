//
//  TestViewModel.swift
//  Cartly
//
//  Created by Khaled Mustafa on 29/05/2025.
//

import SwiftUI

class HomeViewModel: ObservableObject{
    @Published var categories: [CustomCollection] = []
    
    func getCategories(){
        NetworkManager.shared.getProducts {
            
            switch $0{
            case .success(let categories):
                self.categories = categories
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
