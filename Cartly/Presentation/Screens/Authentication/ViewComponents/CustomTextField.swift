//
//  CustomTextFiled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 30/5/25.
//

import SwiftUI

struct CustomTextField: View {
    
    let placeHolder : String
    @Binding var text: String
    let icon: String
    var keyboardType : UIKeyboardType = .default
    
    var body: some View {
        HStack{
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width:20)
            
            TextField(placeHolder , text:$text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text: String = ""
        
        var body: some View {
            VStack(spacing: 20) {
                CustomTextField(
                    placeHolder: "Enter your email",
                    text: $text,
                    icon: "envelope"
                )
                
                CustomTextField(
                    placeHolder: "Enter password",
                    text: $text,
                    icon: "lock",
                    keyboardType: .default
                )
                
                CustomTextField(
                    placeHolder: "Enter phone number",
                    text: $text,
                    icon: "phone",
                    keyboardType: .phonePad
                )
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
