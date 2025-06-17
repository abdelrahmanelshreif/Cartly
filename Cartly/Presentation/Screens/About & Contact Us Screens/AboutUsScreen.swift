//
//  AboutUsScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import SwiftUI

struct AboutUsView: View {
    
    var backgroundLayer: some View {
        LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .opacity(0.03)
                    .rotationEffect(.degrees(-25))
                    .offset(x: 100, y: 200)
            )
    }
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("About Us")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Who We Are")
                                .font(.title2).bold()
                            Text("Cartly is a modern e-commerce app offering seamless shopping experiences with a focus on speed, security, and user satisfaction.")
                        }
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Our Mission")
                                .font(.title2).bold()
                            Text("To simplify online shopping while providing an intuitive, fast, and elegant experience.")
                        }
                    }

                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .ignoresSafeArea()
    }
}



#Preview {
    AboutUsScreen()
}
