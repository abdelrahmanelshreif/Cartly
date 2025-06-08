//
//  LoadingView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 3/6/25.
//
import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .padding(.top)
        }
    }
}
