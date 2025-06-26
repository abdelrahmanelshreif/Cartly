//
//  Untitled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct SizeSelectionView: View {
    let sizes: [String]
    @Binding var selectedSize: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Size")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sizes, id: \.self) { size in
                        Button(action: {
                            selectedSize = size
                        }) {
                            Text(size)
                                .font(.subheadline)
                                .foregroundColor(selectedSize == size ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedSize == size ? Color.blue : Color.gray.opacity(0.2))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedSize == size ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }
}
