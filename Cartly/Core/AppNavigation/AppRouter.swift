//
//  NavigationManager.swift
//  Cartly
//
//  Created by Khaled Mustafa on 07/06/2025.
//

import Combine
import SwiftUI

@MainActor
class AppRoute: ObservableObject{
    @Published var path: NavigationPath = NavigationPath()
    
}
