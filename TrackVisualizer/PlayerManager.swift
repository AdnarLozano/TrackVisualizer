import Foundation
import AVFoundation
import Combine

class PlayerManager: ObservableObject {
    @Published var isPlaying = false
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()

    func play(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
    }

    func togglePlayPause(url: URL) {
        if isPlaying {
            pause()
        } else {
            play(url: url)
        }
    }
}
