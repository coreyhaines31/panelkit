import SwiftUI

/// A thin horizontal level bar. Graphite by default; tinted only for caution or stop.
public struct Tape: View {
    /// Filled fraction (0...1).
    public var fraction: Double
    /// Tint; nil or `.go` keeps the graphite fill.
    public var status: PanelStatus?
    /// Where the level is headed (0...1), drawn as a faint extension past the fill; ignored when not ahead of it.
    public var projection: Double?

    @Environment(\.panelTheme) private var theme

    /// Creates a tape, optionally with a faint projection to where the level is headed.
    public init(_ fraction: Double, projection: Double? = nil, status: PanelStatus? = nil) {
        self.fraction = fraction
        self.projection = projection
        self.status = status
    }

    private static func clamp(_ value: Double) -> Double { min(max(value, 0), 1) }

    private var fillColor: Color {
        switch status {
        case .caution: theme.caution
        case .stop: theme.stop
        default: theme.fill
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle().fill(theme.track)
                if let projection, projection > fraction {
                    Rectangle()
                        .fill(fillColor.opacity(0.22))
                        .frame(width: proxy.size.width * Self.clamp(projection))
                }
                Rectangle()
                    .fill(fillColor)
                    .frame(width: proxy.size.width * Self.clamp(fraction))
            }
        }
        .frame(height: 5)
        .clipShape(RoundedRectangle(cornerRadius: 1))
        .accessibilityElement()
        .accessibilityValue(spokenValue)
    }

    private var spokenValue: String {
        let now = "\(Int((Self.clamp(fraction) * 100).rounded())) percent"
        guard let projection, projection > fraction else { return now }
        return "\(now), headed for \(Int((Self.clamp(projection) * 100).rounded())) percent"
    }
}
