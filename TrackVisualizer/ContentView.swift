import SwiftUI

struct ContentView: View {
    @StateObject private var tracklistManager = TracklistManager()
    @StateObject private var playerManager = PlayerManager()
    @State private var selectedTrack: URL?
    @State private var waveformData: [Float] = [] // Store waveform data
    @State private var isLoadingWaveform = false // Track loading state

    var body: some View {
        VStack {
            // Waveform at the top with top margin and increased height
            ScrollView(.horizontal) {
                if isLoadingWaveform {
                    ProgressView("Loading Waveform...")
                        .frame(height: 100) // Increased to 100 pixels
                        .frame(width: 200)
                        .background(Color.black.opacity(0.8))
                } else {
                    WaveformView(data: waveformData)
                        .frame(height: 100) // Increased to 100 pixels
                        .frame(width: max(200, CGFloat(waveformData.count) * (2 + 1))) // 2 for bar width, 1 for spacing
                        .background(Color.black.opacity(0.8))
                        .padding(.top, 25) // Added 10-point top margin
                        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                            handleDrop(providers: providers)
                        }
                }
            }
            .padding(.horizontal)

            // Button Container (Import Tracks and Playback Controls)
            HStack {
                Button("Import Tracks") {
                    importTracks()
                }
                .padding()

                Button("Delete Selected Track") {
                    if let selectedTrack = selectedTrack, let index = tracklistManager.tracks.firstIndex(of: selectedTrack) {
                        deleteTracks(at: IndexSet(integer: index))
                    }
                }
                .padding()
                .disabled(selectedTrack == nil)

                HStack(spacing: 10) {
                    Button(action: {
                        if let selectedTrack = selectedTrack {
                            startAccessingSecurityScopedResource(for: selectedTrack) {
                                playerManager.togglePlayPause(url: selectedTrack)
                            }
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
                ForEach(tracklistManager.tracks.indices, id: \.self) { index in
                    let track = tracklistManager.tracks[index]
                    Text(track.lastPathComponent)
                        .tag(track)
                        .onTapGesture(count: 2) {
                            selectedTrack = track
                            startAccessingSecurityScopedResource(for: track) {
                                playerManager.togglePlayPause(url: track)
                                loadWaveform(for: track)
                            }
                        }
                        .contextMenu {
                            Button("Delete") {
                                deleteTracks(at: IndexSet(integer: index))
                            }
                        }
                }
                .onDelete(perform: deleteTracks)
            }
            .frame(minWidth: 200)
            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
            // Updated onChange with two-parameter closure
            .onChange(of: selectedTrack) { oldValue, newValue in
                if let track = newValue {
                    loadWaveform(for: track)
                } else {
                    waveformData = []
                }
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }

    private func deleteTracks(at offsets: IndexSet) {
        tracklistManager.tracks.remove(atOffsets: offsets)
        if let selectedTrack = selectedTrack, !tracklistManager.tracks.contains(selectedTrack) {
            self.selectedTrack = nil
            playerManager.stop()
            waveformData = []
        }
    }

    private func importTracks() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.mp3, .wav]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Users/hostname/Desktop/Songs")
        if panel.runModal() == .OK {
            let newTracks = panel.urls.filter { !tracklistManager.tracks.contains($0) }
            for url in newTracks {
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security-scoped resource for \(url)")
                    continue
                }
                tracklistManager.tracks.append(url)
                url.stopAccessingSecurityScopedResource()
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url, (url.pathExtension.lowercased() == "mp3" || url.pathExtension.lowercased() == "wav") {
                        DispatchQueue.main.async {
                            if !tracklistManager.tracks.contains(url) {
                                guard url.startAccessingSecurityScopedResource() else {
                                    print("Failed to access security-scoped resource for \(url) via drag-and-drop")
                                    return
                                }
                                tracklistManager.tracks.append(url)
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                    }
                }
            }
        }
        return true
    }

    private func startAccessingSecurityScopedResource(for url: URL, completion: @escaping () -> Void) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to start accessing security-scoped resource for \(url)")
            return
        }
        completion()
        url.stopAccessingSecurityScopedResource()
    }

    private func loadWaveform(for url: URL) {
        isLoadingWaveform = true
        Task {
            do {
                let data = try await AudioProcessor.extractWaveformData(from: url)
                DispatchQueue.main.async {
                    self.waveformData = data
                    self.isLoadingWaveform = false
                }
            } catch {
                print("Failed to load waveform: \(error)")
                DispatchQueue.main.async {
                    self.waveformData = []
                    self.isLoadingWaveform = false
                }
            }
        }
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
