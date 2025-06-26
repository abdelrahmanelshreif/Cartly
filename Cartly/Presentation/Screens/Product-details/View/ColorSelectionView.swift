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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            HStack {
                                Circle()
                                    .fill(colorForName(color))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Text(color.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedColor == color ? Color.blue.opacity(0.1) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedColor == color ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "black": return .black
        case "white": return .white
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "gray", "grey": return .gray
        case "brown": return .brown
        default: return .gray
        }
    }
}
