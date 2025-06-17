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
        VStack(spacing: 12) { 
            Image("profile-avatar")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
            VStack(spacing: 4) {
                Text(user?.name ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(user?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
     
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 10)
    }
}
