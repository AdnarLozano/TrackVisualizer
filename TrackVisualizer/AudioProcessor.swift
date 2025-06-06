import Foundation
import AVFoundation

class AudioProcessor {
    // Extracts amplitude samples from an audio file for waveform display
    static func extractWaveformData(from url: URL, sampleCount: Int = 1000) async throws -> [Float] {
        // Ensure we have access to the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            throw AudioProcessingError.securityScopeAccessFailed
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Load the audio file using AVURLAsset (fix for macOS 15.0 deprecation)
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw AudioProcessingError.noAudioTrackFound
        }

        // Get the duration
        let duration = try await asset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)

        // Create an AVAssetReader
        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1, // Mono
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        
        // Calculate the number of samples to read per bin
        guard reader.startReading() else {
            throw AudioProcessingError.readerFailedToStart
        }

        var samples: [Float] = []
        let totalSamples = Int(durationInSeconds * 44100) // Assuming 44.1kHz sample rate
        let samplesPerBin = max(1, totalSamples / sampleCount)

        // Read audio samples
        var binSum: Float = 0 // Declare outside loop
        var binCount = 0 // Declare outside loop
        while reader.status == .reading {
            guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else { continue }
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
            
            let bufferLength = CMBlockBufferGetDataLength(blockBuffer) / MemoryLayout<Int16>.size
            var bufferData = [Int16](repeating: 0, count: bufferLength)
            CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: bufferLength * MemoryLayout<Int16>.size, destination: &bufferData)

            // Process samples in bins
            for i in 0..<bufferLength {
                let sample = Float(bufferData[i]) / 32768.0 // Normalize to [-1, 1]
                binSum += abs(sample)
                binCount += 1

                if binCount == samplesPerBin {
                    let average = binSum / Float(binCount)
                    samples.append(average)
                    binSum = 0
                    binCount = 0
                }
            }
        }

        // Handle remaining samples
        if binCount > 0 {
            let average = binSum / Float(binCount)
            samples.append(average)
        }

        // Trim or pad to match sampleCount
        if samples.count > sampleCount {
            samples = samples.prefix(sampleCount).map { $0 }
        } else if samples.count < sampleCount {
            samples.append(contentsOf: Array(repeating: 0.0, count: sampleCount - samples.count))
        }

        return samples
    }
}

enum AudioProcessingError: Error {
    case securityScopeAccessFailed
    case noAudioTrackFound
    case readerFailedToStart
}
