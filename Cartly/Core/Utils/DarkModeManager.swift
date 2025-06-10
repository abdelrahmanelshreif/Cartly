//
//  DarkModeManager.swift
//  Cartly
//
//  Created by Khalid Amr on 10/06/2025.
//

import Foundation
import Combine
import SwiftUI

final class DarkModeManager: ObservableObject {
    static let shared = DarkModeManager()
    
    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode")

    private var cancellables = Set<AnyCancellable>()

    private init() {
        $isDarkMode
            .removeDuplicates()
            .sink { newValue in
                UserDefaults.standard.set(newValue, forKey: "isDarkMode")
            }
            .store(in: &cancellables)
    }
}
