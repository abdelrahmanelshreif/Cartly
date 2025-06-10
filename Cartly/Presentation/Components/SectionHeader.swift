import SwiftUI

struct SectionHeader: View {
    let headerText: String
    var body: some View {
        HStack {
            Text(headerText)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .kerning(1.2)
                .padding(.vertical, 4)
                .overlay(
                    Rectangle()
                        .frame(height: 3)
                        .foregroundColor(.blue)
                        .offset(y: 8),
                    alignment: .bottom
                )
            Spacer()
        }
    }
}
