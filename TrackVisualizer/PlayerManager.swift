import Foundation
import AVFoundation
import Combine

class PlayerManager: ObservableObject {
    @Published var isPlaying = false
    private var player: AVPlayer?
    private var currentURL: URL?
    private var cancellables = Set<AnyCancellable>()
    private var lastPlayTime: Date?
    private var isAudioReady = false

    var audioReady: Bool {
        return isAudioReady
    }

    func play(url: URL) {
        guard lastPlayTime == nil || Date().timeIntervalSince(lastPlayTime!) > 1.0 else {
            print("Playback throttled to avoid rate-limit")
            return
        }
        if currentURL != url || player == nil {
            print("Creating new player for URL: \(url.absoluteString)")
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            currentURL = url
            // Observe status with delay for readiness
            player?.currentItem?.publisher(for: \.status)
                .sink { [weak self] status in
                    if let self = self {
                        print("Player status changed to: \(status.rawValue)")
                        if status == .readyToPlay {
                            self.isAudioReady = true
                            DispatchQueue.main.async {
                                self.player?.play()
                                self.isPlaying = true
                                print("Playback resumed after ready state")
                            }
                        } else if status == .unknown {
                            print("Status unknown, waiting for readiness")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                if let self = self, !self.isAudioReady {
                                    print("Still not ready, resetting player. Error: \(self.player?.currentItem?.error?.localizedDescription ?? "None")")
                                    self.player = nil
                                    self.isPlaying = false
                                }
                            }
                        } else if status == .failed {
                            print("Playback failed: \(self.player?.currentItem?.error?.localizedDescription ?? "Unknown error")")
                            self.player = nil
                            self.isPlaying = false
                        }
                    }
                }
                .store(in: &cancellables)
            // Observe rate
            player?.publisher(for: \.rate)
                .sink { [weak self] rate in
                    print("Player rate changed to: \(rate)")
                    if let self = self, rate == 0, self.isPlaying, self.player?.currentItem?.status != .readyToPlay {
                        print("Playback stopped unexpectedly, resetting")
                        self.isPlaying = false
                    }
                }
                .store(in: &cancellables)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
        // Always attempt to play if the player exists
        if player != nil {
            print("Resuming playback for existing player")
            player?.play()
            isPlaying = true
        }
        lastPlayTime = Date()
        print("Playback started: \(isPlaying), audio ready: \(isAudioReady), rate: \(player?.rate ?? -1)")
    }

    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        print("Playback finished")
    }

    func pause() {
        print("Pausing playback")
        player?.pause()
        isPlaying = false
        print("Playback paused: \(isPlaying), rate: \(player?.rate ?? -1)")
    }

    func stop() {
        print("Stopping playback")
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        print("Playback stopped: \(isPlaying), rate: \(player?.rate ?? -1)")
    }

    func togglePlayPause(url: URL) {
        print("Toggling playback for URL: \(url.absoluteString)")
        if isPlaying {
            pause()
        } else {
            play(url: url)
        }
    }
}
