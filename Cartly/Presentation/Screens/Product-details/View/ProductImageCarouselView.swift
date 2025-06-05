//
//  ProductImageCarouselView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct ProductImageCarouselView: View {
    let images: [ProductInfromationImageEntity]
    @Binding var selectedIndex: Int
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImage(url: URL(string: images[index].url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
    }
}
