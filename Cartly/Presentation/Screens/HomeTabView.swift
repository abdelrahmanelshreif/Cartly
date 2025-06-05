import SwiftUI

struct HomeTabView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            CategoryScreen()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Categories")
                }
            MyFavouriteScreen()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Favourites ")
                }
            ProfileScreen()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Profile ")
                }
        }
        .accentColor(.black)
    }
}
