import SwiftUI

struct WaveformView: View {
    let data: [Double]

    var body: some View {
        Canvas { context, size in
            let path = createWaveformPath(data: data, in: size)
            context.stroke(path, with: .color(.white), lineWidth: 1)
        }
        .frame(height: 200)
    }

    private func createWaveformPath(data: [Double], in size: CGSize) -> Path {
        let step = size.width / CGFloat(data.count - 1)
        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height / 2))

        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * step
            let y = size.height / 2 * (1 - CGFloat(value)) // Invert for upward waveform
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

#if DEBUG
struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(data: PreviewContent.sampleWaveformData)
            .preferredColorScheme(.dark)
    }
}
#endif
