import Foundation

class TracklistManager: ObservableObject {
    @Published var tracks: [URL] = []
}
