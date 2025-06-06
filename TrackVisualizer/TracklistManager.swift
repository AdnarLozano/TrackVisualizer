import Foundation

class TracklistManager: ObservableObject {
    @Published var tracks: [URL] = [] {
        didSet {
            saveTracks()
        }
    }

    private let defaults = UserDefaults.standard
    private let bookmarkKey = "TrackVisualizerBookmarks"

    init() {
        print("TracklistManager initializing...")
        do {
            try loadTracks()
            print("TracklistManager initialized with \(tracks.count) tracks")
            for track in tracks {
                print("Loaded track: \(track.absoluteString), isFileURL: \(track.isFileURL), exists: \(FileManager.default.fileExists(atPath: track.path))")
            }
        } catch {
            print("Failed to load tracks: \(error)")
            tracks = []
        }
    }

    private func saveTracks() {
        print("Saving \(tracks.count) tracks to UserDefaults...")
        var bookmarkDataArray: [Data] = []
        for url in tracks {
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to start accessing security-scoped resource for \(url) during save")
                continue
            }
            do {
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                print("Successfully created bookmark for \(url.absoluteString)")
                bookmarkDataArray.append(bookmarkData)
            } catch {
                print("Failed to create bookmark for \(url): \(error)")
            }
            url.stopAccessingSecurityScopedResource()
        }
        // Synchronously save to ensure data is written
        defaults.synchronize()
        defaults.set(bookmarkDataArray, forKey: bookmarkKey)
        print("Bookmarks saved successfully, count: \(bookmarkDataArray.count)")
    }

    private func loadTracks() throws {
        print("Loading tracks from UserDefaults...")
        guard let bookmarkDataArray = defaults.array(forKey: bookmarkKey) as? [Data] else {
            print("No bookmarks found in UserDefaults")
            return
        }

        var loadedTracks: [URL] = []
        for (index, bookmarkData) in bookmarkDataArray.enumerated() {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if url.isFileURL, FileManager.default.fileExists(atPath: url.path) {
                    loadedTracks.append(url)
                    print("Successfully resolved bookmark for \(url.absoluteString)")
                } else {
                    print("Bookmark resolved to invalid URL: \(url)")
                }
            } catch {
                print("Failed to resolve bookmark at index \(index): \(error)")
            }
        }

        print("Loaded \(loadedTracks.count) tracks from bookmarks")
        self.tracks = loadedTracks
    }
}
