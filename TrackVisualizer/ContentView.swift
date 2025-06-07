import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var tracklistManager = TracklistManager()
    @StateObject private var playerManager = PlayerManager()
    @State private var selectedTrack: URL?
    @State private var waveformData: [Float] = [] // Store waveform data
    @State private var isLoadingWaveform = false // Track loading state
    @State private var progress: Double = 0.0 // Progress for the slider
    @State private var isAnalyzing = false // Track analysis state

    var body: some View {
        VStack {
            // Waveform and Button section with fixed height
            VStack {
                WaveformView(data: waveformData, currentPosition: progress, duration: playerManager.duration)
                    .frame(height: 100) // Waveform height
                
                // Progress Bar
                Slider(value: $progress, in: 0...max(playerManager.duration, 1), step: 0.1)
                    .accentColor(.green)
                    .disabled(playerManager.duration == 0 || isAnalyzing)
                    .onChange(of: progress) { oldValue, newValue in
                        playerManager.currentTime = newValue // Update playback position
                    }
                    .onChange(of: playerManager.currentTime) { oldValue, newValue in
                        progress = newValue // Sync slider with playback
                    }
                    .padding(.horizontal)
                
                // Buttons container
                HStack {
                    Button("Import") {
                        importTracks()
                    }
                    .padding()

                    Button("Delete") {
                        if let selectedTrack = selectedTrack, let index = tracklistManager.tracks.firstIndex(of: selectedTrack) {
                            deleteTracks(at: IndexSet(integer: index))
                        }
                    }
                    
                    Spacer()    // Push buttons to the left and play controls to the center
                    
                    Button(action: {
                        if playerManager.isPlaying {
                            playerManager.pause()
                        } else if let track = selectedTrack, !isAnalyzing {
                            playerManager.play(url: track)
                        }
                    }) {
                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                    }
                    .padding(.horizontal)
                    .disabled(isAnalyzing)

                    Button(action: {
                        playerManager.stop()
                    }) {
                        Image(systemName: "stop.fill")
                    }
                    .padding(.horizontal)
                    .disabled(isAnalyzing)

                    Spacer()    // Push play controls to the center
                }
                .padding(.vertical)
            }
            .frame(height: 200) // Fixed total height for waveform and buttons

            // Tracklist (flexible height)
            List(selection: $selectedTrack) {
                ForEach(tracklistManager.tracks.indices, id: \.self) { index in
                    let track = tracklistManager.tracks[index]
                    Text(track.lastPathComponent)
                        .tag(track)
                        .onTapGesture(count: 2) {
                            selectedTrack = track
                            loadWaveform(for: track)
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
        .frame(minWidth: 600, idealWidth: 1200, maxWidth: .infinity, minHeight: 210, idealHeight: 370) // Adjusted minHeight and idealHeight
    }

    private func deleteTracks(at offsets: IndexSet) {
        tracklistManager.tracks.remove(atOffsets: offsets)
        if let selectedTrack = selectedTrack, !tracklistManager.tracks.contains(selectedTrack) {
            self.selectedTrack = nil
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
        isAnalyzing = true // Start analyzing
        Task {
            do {
                // Load duration from the audio file
                let asset = AVURLAsset(url: url)
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                
                // Update PlayerManager duration
                DispatchQueue.main.async {
                    self.playerManager.duration = durationSeconds.isFinite ? durationSeconds : 0.0
                }
                
                let data = try await AudioProcessor.extractWaveformData(from: url)
                DispatchQueue.main.async {
                    self.waveformData = data
                    self.isLoadingWaveform = false
                    self.isAnalyzing = false // Analysis complete
                }
            } catch {
                print("Failed to load waveform: \(error)")
                DispatchQueue.main.async {
                    self.waveformData = []
                    self.isLoadingWaveform = false
                    self.isAnalyzing = false // Analysis failed
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
