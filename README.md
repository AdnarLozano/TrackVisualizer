# TrackVisualizer

A macOS app to visualize audio waveforms with an energy-based color spectrum, inspired by tools like Minimeters and Serato. Designed for personal use to assist with mastering and track analysis.

## Features

- Visualize 3–5 minute tracks (SwiftUI version) and 1–2 hour DJ sets (future Metal version).
- Energy-based color mapping with 11 frequency bands (20Hz–20kHz), from deep crimson to magenta.
- Drag-and-drop WAV/MP3 file import with playback controls (play, stop, rewind, forward).
- Horizontal waveform scroll view with a tracklist sidebar.

## Installation

1. Clone the repository:

git clone https://github.com/AdnarLozano/TrackVisualizer.git

2. Open `TrackVisualizer.xcodeproj` in Xcode.
3. Build and run on macOS.

## Usage

- Drag WAV or MP3 files into the waveform view or tracklist, or use the "Import Tracks" button.
- Scroll the waveform to analyze energy across frequency bands.
- Use playback controls to navigate the track.

## License

MIT License (see [LICENSE](LICENSE) for details).
