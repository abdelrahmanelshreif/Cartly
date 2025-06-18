//
//  NoConnectionScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import SwiftUI

struct NoConnectionScreen: View {
    @EnvironmentObject private var reachability: NetworkMonitor
    
    var body: some View {
            VStack(spacing: 24) {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)

                Text("No Internet Connection")
                    .font(.title2)
                    .bold()

                Text("Please check your connection and try again.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding()
        }
}
