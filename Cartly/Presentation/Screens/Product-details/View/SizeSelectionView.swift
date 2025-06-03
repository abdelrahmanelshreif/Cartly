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
            	
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(sizes, id: \.self) { size in
                    Button(action: {
                        selectedSize = size
                    }) {
                        Text(size)
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedSize == size ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedSize == size ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
