//
//  GlassCard.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(.ultraThinMaterial)
            .background(.ultraThinMaterial)
            .overlay(
                content
                    .padding()
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}

//#Preview {
//    GlassCard(content: <#() -> _#>)
//}
