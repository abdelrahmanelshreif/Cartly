import AVFoundation
import SwiftUI

struct SplashScreen: View {
    
    @StateObject private var viewModel: SplashViewModel
    @EnvironmentObject var router: AppRouter
    private let player: AVPlayer

    init() {
        _viewModel = StateObject(wrappedValue: SplashViewModel())
        player = AVPlayer(url: Bundle.main.url(forResource: "splash", withExtension: "mp4")!)
    }

    var body: some View {
        Group {
            VideoPlayerView(player: player)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            print("on splash onAppear")
            player.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                viewModel.navigate(router: router)
            }
        }
        .onDisappear {
            print("on splash disappear")
            player.pause()
        }
    }
}
