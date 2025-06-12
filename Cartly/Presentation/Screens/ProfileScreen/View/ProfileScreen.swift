//
//  ProfileScreen.swift
//  Cartly
//
//  Created by Khaled Mustafa on 04/06/2025.
//

import Combine
import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ProfileViewModel = DIContainer.shared
        .resolveProfileViewModel()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Group {
                if viewModel.currentUser?.sessionStatus == true {
                    ScrollView {
                        VStack(spacing: 0) {
                            ProfileHeaderView(user: viewModel.currentUser)
                                .padding(20)

                            VStack(spacing: 16) {
                                ProfileMenuSection(title: "My Account") {
                                    ProfileMenuItem(
                                        icon: "box.truck",
                                        title: "Orders",
                                        subtitle:
                                            "Track, return, or buy things again"
                                    ) {
                                        // Navigate to orders
                                    }

                                    ProfileMenuItem(
                                        icon: "location",
                                        title: "Addresses",
                                        subtitle:
                                            "Edit addresses for orders and gifts"
                                    ) {
                                        // Navigate to addresses
                                    }

                                    ProfileMenuItem(
                                        icon: "creditcard",
                                        title: "Payment Methods",
                                        subtitle: "Add or edit payment methods"
                                    ) {
                                        // Navigate to payment methods
                                    }
                                }

                                Button(action: {
                                    viewModel.signOut()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.circle.fill")
                                            .font(.title3)
                                        Text(
                                            viewModel.loading
                                                ? "Signing Out..." : "Sign Out"
                                        )
                                        .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .disabled(viewModel.loading)
                            }
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if viewModel.loading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .blue))
                        Text("Signing out...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LoggedOutView {
                        router.setRoot(.authentication)
                    }
                }
            }
        }
        .onAppear {
            viewModel.checkUserSession()
        }
    }
}
