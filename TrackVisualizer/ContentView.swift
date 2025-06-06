import SwiftUI

struct ContentView: View {
    @StateObject private var tracklistManager = TracklistManager()
    @State private var selectedTrack: URL?

    var body: some View {
        HStack {
            // Waveform and Controls
            VStack {
                // Waveform
                ScrollView(.horizontal) {
                    WaveformView()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.8))
                        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                            handleDrop(providers: providers)
                        }
                }
                .padding()

                // Playback Controls
                HStack {
                    Button(action: { /* Play */ }) { Image(systemName: "play.fill") }
                    Button(action: { /* Stop */ }) { Image(systemName: "stop.fill") }
                    Button(action: { /* Rewind */ }) { Image(systemName: "backward.fill") }
                    Button(action: { /* Forward */ }) { Image(systemName: "forward.fill") }
                }
                .padding()
            }

            // Tracklist
            VStack {
                Button("Import Tracks") {
                    importTracks()
                }
                .padding()

                List(tracklistManager.tracks, id: \.self, selection: $selectedTrack) { track in
                    Text(track.lastPathComponent)
                }
                .frame(minWidth: 200)
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
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
