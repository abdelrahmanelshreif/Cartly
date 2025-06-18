//
//  ContactUsScreen.swift
//  Cartly
//
//  Created by Khalid Amr on 18/06/2025.
//

import SwiftUI

import SwiftUI

struct ContactUsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Contact Us")
                    .font(.title2).bold()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("We’d love to hear from you.")
                        .font(.headline)

                    Text("Feel free to reach out to us through any of the following methods.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    ContactRow(icon: "envelope.fill", title: "Email", value: "support@cartly.com")
                    ContactRow(icon: "phone.fill", title: "Phone", value: "+20 123 456 7890")
                    ContactRow(icon: "globe", title: "Website", value: "www.cartly.com")
                    ContactRow(icon: "location.fill", title: "Address", value: "12 Tahrir Street, Cairo, Egypt")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Contact Us")
    }
}

struct ContactRow: View {
    var icon: String
    var title: String
    var value: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

