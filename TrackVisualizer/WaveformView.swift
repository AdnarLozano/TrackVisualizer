import SwiftUI

struct WaveformView: View {
    let data: [Float]
    let currentPosition: Double // Playback position in seconds
    let duration: Double // Total duration in seconds
    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = CGFloat(data.count) * (barWidth + barSpacing)
            let totalHeight = geometry.size.height
            let visibleWidth = geometry.size.width
            let centerX = visibleWidth / 2 // Center of the visible window area

            // Calculate the offset based on current playback position
            let playbackOffset: CGFloat = duration > 0 ? {
                let samplesPerSecond = Double(data.count) / duration
                let playedSamples = Int(currentPosition * samplesPerSecond)
                return CGFloat(playedSamples) * (barWidth + barSpacing)
            }() : 0

            ZStack(alignment: .center) {
                // Waveform bars, starting at center and moving left
                HStack(spacing: barSpacing) {
                    if data.isEmpty {
                        Spacer()
                            .frame(width: visibleWidth) // Placeholder for empty data
                    } else {
                        ForEach(0..<data.count, id: \.self) { index in
                            let sample = data[index]
                            let height = CGFloat(sample) * totalHeight
                            Rectangle()
                                .frame(width: barWidth, height: max(1, height))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: totalWidth)
                .offset(x: centerX - playbackOffset) // Start at center, move left with playback

                // Fixed playback position indicator (vinyl needle)
                Rectangle()
                    .frame(width: 1, height: totalHeight)
                    .foregroundColor(.red)
                    .position(x: centerX, y: totalHeight / 2)
            }
            .frame(width: totalWidth, height: totalHeight, alignment: .leading)
        }
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(data: [0.1, 0.3, 0.5, 0.7, 0.9, 0.7, 0.5, 0.3, 0.1], currentPosition: 0.0, duration: 10.0)
            .frame(height: 100)
            .background(Color.black.opacity(0.8))
    }
}
