import SwiftUI

struct SearchButton: View {
    var body: some View {
        Button(action: {
            // Handle search tap
        }) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}
