//
//  SplashScreen.swift
//  Muvo
//
//  Created by Frengky Gunawan on 16/06/25.
//

import SwiftUI
import AVKit

struct SplashScreenView: View {
    @State private var isVideoFinished = false

    var body: some View {
        ZStack {
            if isVideoFinished {
                ContentView()
            } else {
                VideoPlayerView(isFinished: $isVideoFinished)
                    .ignoresSafeArea()
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    @Binding var isFinished: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        guard let path = Bundle.main.path(forResource: "splashScreen", ofType:"mov") else {
            print("Video not found")
            return controller
        }

        let player = AVPlayer(url: URL(fileURLWithPath: path))
        controller.player = player
        controller.showsPlaybackControls = false

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            isFinished = true
        }
        
        player.playImmediately(atRate: 1.0)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
