//
//  SignupView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject var viewModel = DIContainer.shared.resolveSignUpViewModel()
    @StateObject var loginViewModel = DIContainer.shared.resolveLoginViewModel()
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            Image("Cartly")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .foregroundColor(Color.blue)

            VStack(spacing: 16) {
                CustomTextField(
                    placeHolder: "First Name", text: $viewModel.firstName,
                    icon: "person.fill")
                CustomTextField(
                    placeHolder: "Last Name", text: $viewModel.lastName,
                    icon: "person.fill")
                CustomTextField(
                    placeHolder: "Email", text: $viewModel.email,
                    icon: "envelope.fill", keyboardType: .emailAddress)
                CustomTextField(
                    placeHolder: "Phone", text: $viewModel.phone,
                    icon: "phone.fill", keyboardType: .phonePad)
                CustomSecureField(
                    placeHolder: "Password", text: $viewModel.password,
                    isVisible: $isPasswordVisible, icon: "lock.fill")

                if let validationError = viewModel.validationError {
                    Text(validationError)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                switch viewModel.resultState {
                case .loading:
                    ProgressView()
                case .success(let customer):
                    Text("Welcome, \(customer)!")
                        .foregroundColor(.green)
                        .onAppear {
                            router.setRoot(.main)
                        }
                case .failure(let error):
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                case .none:
                    EmptyView()
                }

                Button(action: {
                    viewModel.createAccount()
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                Button(action: {
                    loginViewModel.loginWithGoogle()
                }) {
                    HStack {
                        Image("google_icon")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Continue with Google")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.4	), lineWidth: 1)
                    )
                    .cornerRadius(15)
                }
            }.padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip") {
                    router.setRoot(.main)
                }
                .foregroundColor(.blue)
            }
        }
    }
}
