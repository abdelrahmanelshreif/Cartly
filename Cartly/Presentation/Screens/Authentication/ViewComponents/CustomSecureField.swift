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
        @State private var isVisible: Bool = false
        
        var body: some View {
            VStack(spacing: 20) {
                CustomSecureField(
                    placeHolder: "Enter your password",
                    text: $text,
                    isVisible: $isVisible,
                    icon: "lock.fill"

                )
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
