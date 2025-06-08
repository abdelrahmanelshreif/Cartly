import SwiftUI

struct HomeTabView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab){
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }.tag(1)
            CategoryScreen()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Categories")
                }.tag(2)
            WishlistScreen()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favourites ")
                }.tag(3)
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile ")
                }.tag(4)
        }
        .accentColor(.black)
    }
}
