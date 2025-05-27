//
//  SignUpView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 26/5/25.
//
import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {ø
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
            
            Button("Create Account") {
                authViewModel.signUp(email: email, password: password)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Create Account")
    }
}

