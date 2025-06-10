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
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.blue)
                .padding(.vertical, 20)

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
                    router.setRoot(.main)
                }) {
                    Text("Guest Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.gray)
                        .cornerRadius(15)
                }
            }.padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
