
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject var viewModel = DIContainer.shared.resolveLoginViewModel()
    @State private var isPasswordVisible = false
    @Environment(\.dismiss) var dismiss

    var body: some View {

        VStack(spacing: 20) {
            Text("Login")
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
                    placeHolder: "Email",
                    text: $viewModel.email,
                    icon: "envelope.fill",
                    keyboardType: .emailAddress
                )
                CustomSecureField(
                    placeHolder: "Password",
                    text: $viewModel.password,
                    isVisible: $isPasswordVisible,
                    icon: "lock.fill"
                )

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
                
                Button(action: {
                    viewModel.loginWithGoogle()
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
                            .stroke(Color.gray.opacity(0.4    ), lineWidth: 1)
                    )
                    .cornerRadius(15)
                }
                Button(action: {
                    router.push(AuthRoute.Signup)
                }) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text("Register")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip") {
                    router.setRoot(.main)
                }
                .foregroundColor(.blue)
            }
        }
    }
}

