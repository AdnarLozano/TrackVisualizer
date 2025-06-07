import Foundation
import AVFoundation
import Combine

class PlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0.0 // Current playback time in seconds
    @Published var duration: Double = 0.0 // Total duration of the track in seconds
    private var player: AVPlayer?
    private var currentURL: URL?
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?
    private let timeObservationInterval: Double = 0.05 // Configurable interval

    // MARK: - Public Methods
    func play(url: URL) {
        guard currentURL != url || player == nil else {
            player?.play()
            isPlaying = true
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        currentURL = url

        // Single observer for status and duration
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    if let duration = self.player?.currentItem?.duration.seconds {
                        self.duration = duration.isFinite ? duration : 0.0
                        print("Duration set to: \(self.duration)")
                    }
                    self.isAudioReady = true
                    self.player?.play()
                    self.isPlaying = true
                    print("Playback started")
                case .unknown:
                    print("Status unknown, awaiting readiness")
                case .failed:
                    print("Playback failed: \(self.player?.currentItem?.error?.localizedDescription ?? "Unknown error")")
                    self.resetPlayer()
                @unknown default:
                    print("Unknown player status")
                }
            }
            .store(in: &cancellables)

        // Periodic time observer
        let interval = CMTime(seconds: timeObservationInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let player = self.player else { return }
            let seconds = time.seconds
            self.currentTime = seconds.isFinite ? seconds : 0.0
            // Sync isPlaying with rate if not buffering
            if player.rate == 0 && self.isPlaying && player.currentItem?.status == .readyToPlay {
                self.isPlaying = false
                print("Playback stopped unexpectedly")
            }
        }

        // Handle playback end
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    func pause() {
        player?.pause()
        isPlaying = false
        print("Playback paused")
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        currentTime = 0.0
        isPlaying = false
        print("Playback stopped")
    }

    func seek(to time: Double) {
        guard let player = player, let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
        let seekTime = CMTime(seconds: min(max(time, 0), duration), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seekTime) { [weak self] _ in
            self?.currentTime = time
            print("Seeked to: \(time) seconds")
        }
    }

    // MARK: - Private Helpers
    private var isAudioReady = false {
        didSet {
            print("Audio ready state changed to: \(isAudioReady)")
        }
    }

    private func resetPlayer() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0.0
        duration = 0.0
    }

    @objc private func playerDidFinishPlaying() {
        stop()
        print("Playback finished")
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

//import Foundation
//import AVFoundation
//import Combine
//
//class PlayerManager: ObservableObject {
//    @Published var currentTime: Double = 0.0 // Static for now, will be controlled manually later
//    @Published var duration: Double = 0.0 // Static for now
//    private var cancellables = Set<AnyCancellable>()
//
//    // Placeholder methods (no playback)
//    func play(url: URL) {
//        print("Playback bypassed for now")
//    }
//
//    func pause() {
//        print("Pause bypassed for now")
//    }
//
//    func stop() {
//        print("Stop bypassed for now")
//        currentTime = 0.0
//    }
//
//    func togglePlayPause(url: URL) {
//        print("Toggle playback bypassed for now")
//    }
//}
