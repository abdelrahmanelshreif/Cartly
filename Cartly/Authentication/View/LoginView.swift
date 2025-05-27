//
//  Untitled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Sign In") {
                authViewModel.signIn(email: email, password: password)
            }
            .padding()
            
            NavigationLink("Create Account", destination: SignUpView(authViewModel: authViewModel))
        }
        .padding()
        .navigationTitle("Sign In")
    }
}
