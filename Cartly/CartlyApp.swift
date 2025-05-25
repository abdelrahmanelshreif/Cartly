//
//  CartlyApp.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 25/5/25.
//

import SwiftUI

@main
struct CartlyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
