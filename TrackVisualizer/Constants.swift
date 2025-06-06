import SwiftUI

struct Constants {
    static let frequencyBands: [(range: ClosedRange<Double>, color: Color)] = [
        (20.0...50.0, Color(red: 139/255, green: 0, blue: 0)), // Deep Crimson
        (50.0...100.0, Color.red),                             // Red
        (100.0...200.0, Color.orange),                        // Orange
        (200.0...300.0, Color.yellow),                        // Yellow
        (300.0...500.0, Color(red: 50/255, green: 205/255, blue: 50/255)), // Lime Green
        (500.0...1000.0, Color(red: 0, green: 1, blue: 127/255)), // Spring Green
        (1000.0...2000.0, Color(red: 135/255, green: 206/255, blue: 250/255)), // Baby Blue
        (2000.0...3000.0, Color.blue),                        // Blue
        (3000.0...5000.0, Color(red: 147/255, green: 112/255, blue: 219/255)), // Light Purple
        (5000.0...10000.0, Color(red: 128/255, green: 0, blue: 128/255)), // Deep Purple
        (10000.0...20000.0, Color(red: 1, green: 0, blue: 1))                    // Magenta
    ]
}
