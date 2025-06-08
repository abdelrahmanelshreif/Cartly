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
                    Image(systemName: "heart.fill")
                    Text("Favourites ")
                }
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile ")
                }
        }
        .accentColor(.black)
    }
}
