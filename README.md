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

MIT License

Copyright (c) 2025 Adnar Lozano

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
