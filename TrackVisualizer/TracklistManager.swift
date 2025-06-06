import Foundation

class TracklistManager: ObservableObject {
    @Published var tracks: [URL] = [] {
        didSet {
            saveTracks()
        }
    }

    private let defaults = UserDefaults.standard
    private let tracksKey = "TrackVisualizerTracks"

    init() {
        loadTracks()
    }

    private func saveTracks() {
        let urlsAsStrings = tracks.map { $0.absoluteString }
        defaults.set(urlsAsStrings, forKey: tracksKey)
    }

    private func loadTracks() {
        if let urlsAsStrings = defaults.array(forKey: tracksKey) as? [String] {
            tracks = urlsAsStrings.compactMap { URL(string: $0) }
        }
    }
}
