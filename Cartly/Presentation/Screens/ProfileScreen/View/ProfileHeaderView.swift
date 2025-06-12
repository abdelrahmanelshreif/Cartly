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
        VStack(spacing: 0) {
                Image("profile-avatar"/*systemName: "person.fill"*/)
                    .resizable()
                 //   .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            Text(user?.name ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top,8)

            Text(user?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

}
