//
//  LoginView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 28/5/25.
//
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel(loginUseCase: LoginUseCase(authRepository: AuthRepositoryImpl.shared), validator: LoginValidator())

    @State private var isPasswordVisible = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                Image(systemName: "lock.shield")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.blue)
                    .padding(.vertical, 20)

                VStack(spacing: 16) {
                    CustomTextField(placeHolder: "Email", text: $viewModel.email, icon: "envelope.fill", keyboardType: .emailAddress)
                    CustomSecureField(placeHolder: "Password", text: $viewModel.password, isVisible: $isPasswordVisible, icon: "lock.fill")

                    if let validationError = viewModel.validationError {
                        Text(validationError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    switch viewModel.resultState {
                    case .loading:
                        ProgressView()
                    case .success(let user):
                        Text("Welcome back, \(user)!")
                            .foregroundColor(.green)
                    case .failure(let error):
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                    case .none:
                        EmptyView()
                    }

                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }

                    Button(action: {}) {
                        Text("Don't have acoount ?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text("Register")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }.padding()
            }
        }
    }
}

#Preview {
    LoginView()
}
