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
                    .fill(Color.white)
                    .frame(width: 90, height: 90)

                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .shadow(radius: 4)
            }
            Text(user?.name ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 50)

            Text(user?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }

    }

}
