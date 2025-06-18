import SwiftUI

struct AboutUsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Us")
                    .font(.title2).bold()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome to Cartly")
                        .font(.headline)

                    Text("""
Cartly is your go-to destination for convenient shopping. We aim to provide a seamless and personalized experience from the moment you browse to the final checkout.

Whether you're ordering essentials or discovering new products, our goal is to make every transaction smooth, secure, and satisfying.
""")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Our Mission")
                        .font(.headline)

                    Text("""
To bring simplicity, speed, and security to online shopping for everyone. We're passionate about creating an app that empowers users and enhances everyday life.
""")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("About Us")
    }
}

