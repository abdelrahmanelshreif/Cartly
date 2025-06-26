//
//  ProfileHeaderView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: UserEntity?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(initials)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(user?.name ?? "Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var initials: String {
        guard let name = user?.name else { return "G" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

