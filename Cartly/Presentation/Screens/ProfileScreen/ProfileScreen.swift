//
//  ProfileScreen.swift
//  Cartly
//
//  Created by Khaled Mustafa on 04/06/2025.
//

import SwiftUI
import Combine

struct ProfileScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared.resolveProfileViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - User is Signed In
            if viewModel.currentUser!.sessionStatus {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 40)

                    Text(viewModel.currentUser?.email ?? "Anonymous")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text(viewModel.loading ? "Signing Out…" : "Sign Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.loading ? Color.gray : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.loading)
                }

            // MARK: - Loading State
            } else if viewModel.loading {
                ProgressView("Signing out…")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding(.top, 60)

            // MARK: - Logged Out State
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.orange)

                    Text("No user found")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Please log in to access your profile.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Login") {
                        router.setRoot(.authentication)
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top, 40)
            }
        }
        .padding()
        .onAppear {
            viewModel.checkUserSession()
        }
        .onReceive(viewModel.$didSignOut) { didSignOut in
            if didSignOut {
                router.setRoot(.main)
            }
        }
    }
}
