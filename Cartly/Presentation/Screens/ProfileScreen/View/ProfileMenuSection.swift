//
//  ProfileMenuRowView.swift
//  Cartly
//
//  Created by Abdelrahman Elshreif on 11/6/25.
//

import SwiftUI

// MARK: - Simple Profile Menu Row (Compatible with ProfileScreen)
struct ProfileMenuRowView: View {
    let iconName: String
    let title: String
    var tintColor: Color = .primary

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(tintColor)
                .frame(width: 25)
            
            Text(title)
                .font(.body)
                .foregroundColor(tintColor)
            
            Spacer()
            
            if tintColor != .red {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
struct ProfileMenuRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ProfileMenuRowView(
                iconName: "gearshape.fill",
                title: "Settings"
            )
            
            Divider().padding(.leading)
            
            ProfileMenuRowView(
                iconName: "location.fill",
                title: "Addresses"
            )
            
            Divider().padding(.leading)
            
            ProfileMenuRowView(
                iconName: "arrow.left.circle.fill",
                title: "Sign Out",
                tintColor: .red
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding()
    }
}
