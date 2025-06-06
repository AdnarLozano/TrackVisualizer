import SwiftUI

struct WaveformView: View {
    let data: [Float]
    let currentPosition: Double // Current time in seconds
    let duration: Double // Total duration in seconds
    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let totalHeight = geometry.size.height
            let barCount = Int(totalWidth / (barWidth + barSpacing))
            let step = max(1, data.count / barCount)
            
            ZStack(alignment: .leading) {
                // Waveform bars
                HStack(spacing: barSpacing) {
                    ForEach(0..<barCount, id: \.self) { index in
                        let sampleIndex = index * step
                        let sample = sampleIndex < data.count ? data[sampleIndex] : 0.0
                        let height = CGFloat(sample) * totalHeight
                        Rectangle()
                            .frame(width: barWidth, height: max(1, height))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Playback position indicator
                if duration > 0 {
                    let positionRatio = currentPosition / duration
                    let xPosition = totalWidth * positionRatio
                    Rectangle()
                        .frame(width: 1, height: totalHeight)
                        .foregroundColor(.red)
                        .offset(x: min(max(0, xPosition), totalWidth))
                }
            }
        }
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(data: [0.1, 0.3, 0.5, 0.7, 0.9, 0.7, 0.5, 0.3, 0.1], currentPosition: 2.0, duration: 10.0)
            .frame(height: 100)
            .background(Color.black.opacity(0.8))
    }
}
