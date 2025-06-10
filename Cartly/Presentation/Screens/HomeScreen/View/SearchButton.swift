import SwiftUI

struct SearchButton: View {
    @EnvironmentObject var router: AppRouter
    var body: some View {
        Button(action: {
            // Handle search tap to navigate to search screen
            router.push(Route.Search)
        }) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}
