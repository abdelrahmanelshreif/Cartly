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
        ZStack {
            Color.white
                .ignoresSafeArea()
            GeometryReader { geometry in
                VideoPlayerView(player: player)
                    .frame(
                        width: geometry.size.width * 0.8,
                        height: geometry.size.height * 0.4
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .onAppear {
            print("on splash onAppear")
            player.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                viewModel.navigate(router: router)
            }
        }
        .onDisappear {
            print("on splash disappear")
            player.pause()
        }
    }
}
