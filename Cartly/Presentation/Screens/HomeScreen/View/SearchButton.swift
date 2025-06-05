import SwiftUI

struct SearchButton: View {
    var body: some View {
        Button(action: {
            // Handle search tap to navigate to search screen
        }) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}
