//
//  CustomSecureFiled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//
import SwiftUI

struct CustomSecureField: View {
    
    let placeHolder : String
    @Binding var text: String
    @Binding var isVisible: Bool
    let icon: String
    var keyboardType : UIKeyboardType = .default
    
    var body: some View {
        HStack{
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width:20)
            
         
            if isVisible {
                TextField(placeHolder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            } else {
                SecureField(placeHolder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
            
          
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

