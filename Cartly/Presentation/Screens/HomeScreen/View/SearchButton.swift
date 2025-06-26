import SwiftUI

struct SearchButton: View {
    @EnvironmentObject var router: AppRouter
    var body: some View {
        Button(action: {
            router.push(Route.Search)
        }) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}
