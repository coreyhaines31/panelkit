import SwiftUI

/// A segmented LED level meter (e.g. microphone input): green segments, caution at the top.
public struct LevelMeter: View {
    /// Level (0...1).
    public var level: Double
    /// Number of segments.
    public var segments: Int
    /// Segments from this index up show caution when lit.
    public var cautionFrom: Int

    @Environment(\.panelTheme) private var theme

    /// Creates a level meter.
    public init(level: Double, segments: Int = 8, cautionFrom: Int = 5) {
        self.level = level
        self.segments = segments
        self.cautionFrom = cautionFrom
    }

    public var body: some View {
        let lit = Int((min(max(level, 0), 1) * Double(segments)).rounded())
        HStack(spacing: 2) {
            ForEach(0..<segments, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < lit ? (index >= cautionFrom ? theme.caution : theme.go) : theme.track)
                    .frame(width: 4, height: 12)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Level")
        .accessibilityValue("\(Int((min(max(level, 0), 1) * 100).rounded())) percent")
    }
}
