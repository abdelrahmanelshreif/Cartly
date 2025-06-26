import SwiftUI

struct AboutUsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("Meet the Developers")
                        .font(.headline)
                        .padding(.horizontal)

                    DeveloperView(name: "Khalid Mustafa", imageName: "khalid_mustafa", role: "iOS Developer")
                    DeveloperView(name: "AbdElRahman ElSherif", imageName: "abdelrahman_elsherif", role: "iOS Developer")
                    DeveloperView(name: "Khalid Amr", imageName: "khalid_amr", role: "iOS Developer")
                }


                Spacer(minLength: 40)
            }
        }
        .navigationTitle("About Us")
    }
}

struct DeveloperView: View {
    let name: String
    let imageName: String
    let role: String?

    var body: some View {
        HStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.title3)
                    .bold()
                if let role = role {
                    Text(role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
