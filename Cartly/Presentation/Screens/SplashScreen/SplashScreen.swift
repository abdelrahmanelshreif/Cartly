import SwiftUI
import AVKit

struct SplashScreen: View {
    @State private var navigateToHome = false
    private let player = AVPlayer(url: Bundle.main.url(forResource: "splash", withExtension: "mp4")!)

    var body: some View {
        Group {
            if navigateToHome {
                HomeView()
            } else {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()

                        // Add observer to know when video ends
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            navigateToHome = true
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self)
                    }
            }
        }
    }
}
