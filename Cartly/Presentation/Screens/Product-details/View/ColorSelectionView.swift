//
//  ColorSelectionView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct ColorSelectionView: View {
    let colors: [String]
    @Binding var selectedColor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                    }) {
                        Text(color)
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedColor == color ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedColor == color ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
