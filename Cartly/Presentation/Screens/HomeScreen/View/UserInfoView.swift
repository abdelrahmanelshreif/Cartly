import SwiftUI

struct UserInfoView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("cartly_n")
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
//                Text("Welcome 🤗")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.8)

                Text("Let's Shopping")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}
