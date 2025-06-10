//
//  Untitled.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 9/6/25.
//


import SwiftUI

struct ViewControllerResolver: UIViewControllerRepresentable {
    let onResolve: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            onResolve(rootVC)
        }
    }
}
