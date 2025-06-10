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

            Image(systemName: "lock.shield")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.blue)
                .padding(.vertical, 20)

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

//#Preview {
//    LoginView()
//        .environmentObject(AppRouter())
//}
