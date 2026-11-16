import SwiftUI

/// A segmented LED level meter (e.g. microphone input): green segments, caution near the top, optionally stop at the very top.
public struct LevelMeter: View {
    /// Level (0...1).
    public var level: Double
    /// Number of segments.
    public var segments: Int
    /// Segments from this index up show caution when lit.
    public var cautionFrom: Int
    /// Segments from this index up show stop when lit (e.g. clipping); nil for none.
    public var stopFrom: Int?

    @Environment(\.panelTheme) private var theme

    /// Creates a level meter.
    public init(level: Double, segments: Int = 8, cautionFrom: Int = 5, stopFrom: Int? = nil) {
        self.level = level
        self.segments = segments
        self.cautionFrom = cautionFrom
        self.stopFrom = stopFrom
    }

    private func litColor(_ index: Int) -> Color {
        if let stopFrom, index >= stopFrom { return theme.stop }
        return index >= cautionFrom ? theme.caution : theme.go
    }

    public var body: some View {
        let lit = Int((min(max(level, 0), 1) * Double(segments)).rounded())
        HStack(spacing: 2) {
            ForEach(0..<segments, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < lit ? litColor(index) : theme.track)
                    .frame(width: 4, height: 12)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Level")
        .accessibilityValue("\(Int((min(max(level, 0), 1) * 100).rounded())) percent")
    }
}
