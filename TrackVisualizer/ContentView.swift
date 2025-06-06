import SwiftUI

struct ContentView: View {
    @StateObject private var tracklistManager = TracklistManager()
    @StateObject private var playerManager = PlayerManager()
    @State private var selectedTrack: URL?

    var body: some View {
        VStack {
            // Waveform at the top
            ScrollView(.horizontal) {
                WaveformView(data: PreviewContent.sampleWaveformData)
                    .frame(height: 75) // Set to 50-100 pixels, chose 75 as a middle ground
                    .frame(width: 200) // Match tracklist width initially, will adjust with layout
                    .background(Color.black.opacity(0.8))
                    .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }
            }
            .padding(.horizontal)

            // Button Container (Import Tracks and Playback Controls)
            HStack {
                Button("Import Tracks") {
                    importTracks()
                }
                .padding()

                HStack(spacing: 10) { // Container for playback buttons
                    Button(action: {
                        if let selectedTrack = selectedTrack {
                            playerManager.togglePlayPause(url: selectedTrack)
                        }
                    }) {
                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                    }
                    .disabled(selectedTrack == nil)

                    Button(action: {
                        playerManager.stop()
                    }) {
                        Image(systemName: "stop.fill")
                    }
                    .disabled(!playerManager.isPlaying)

                    Button(action: {
                        // Rewind logic (to be implemented)
                    }) {
                        Image(systemName: "backward.fill")
                    }
                    .disabled(true) // Placeholder

                    Button(action: {
                        // Forward logic (to be implemented)
                    }) {
                        Image(systemName: "forward.fill")
                    }
                    .disabled(true) // Placeholder
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding(.bottom)

            // Tracklist
            List(selection: $selectedTrack) {
                ForEach(tracklistManager.tracks, id: \.self) { track in
                    Text(track.lastPathComponent)
                        .tag(track)
                        .onTapGesture(count: 2) {
                            selectedTrack = track
                            if let selectedTrack = selectedTrack {
                                playerManager.togglePlayPause(url: selectedTrack)
                            }
                        }
                }
            }
            .frame(minWidth: 200) // Ensure tracklist has a minimum width
            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }

    private func importTracks() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.mp3, .wav]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Users/me/Music Production Library")
        if panel.runModal() == .OK {
            tracklistManager.tracks.append(contentsOf: panel.urls)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url, (url.pathExtension.lowercased() == "mp3" || url.pathExtension.lowercased() == "wav") {
                        DispatchQueue.main.async {
                            tracklistManager.tracks.append(url)
                        }
                    }
                }
            }
        }
        return true
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
#endif
