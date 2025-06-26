//
//  LoggedOutView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//

import SwiftUI

struct LoggedOutView: View {
    @EnvironmentObject var router: AppRouter
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("You're not logged in")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(
                    "Sign in to access your profile, track orders, and enjoy personalized shopping"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Button(action: onLogin) {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
    }
}
