//
//  NoConnectionScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import SwiftUI

struct NoConnectionScreen: View {
    @EnvironmentObject private var reachability: NetworkMonitor
    @State private var showCheck = false

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

            Button(action: {
                showCheck = true
            }) {
                Text("Try Again")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)

            if showCheck && reachability.isConnected {
                Text("Connection restored ✅")
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
        .padding()
        .onChange(of: reachability.isConnected) { _, connected in
            if connected {
                showCheck = false
            }
        }
    }
}
