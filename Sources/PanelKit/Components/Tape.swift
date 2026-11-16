import SwiftUI

/// A thin horizontal level bar. Graphite by default; tinted only for caution or stop.
public struct Tape: View {
    /// Filled fraction (0...1).
    public var fraction: Double
    /// Tint; nil or `.go` keeps the graphite fill.
    public var status: PanelStatus?

    @Environment(\.panelTheme) private var theme

    /// Creates a tape.
    public init(_ fraction: Double, status: PanelStatus? = nil) {
        self.fraction = fraction
        self.status = status
    }

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
                Rectangle()
                    .fill(fillColor)
                    .frame(width: proxy.size.width * min(max(fraction, 0), 1))
            }
        }
        .frame(height: 5)
        .clipShape(RoundedRectangle(cornerRadius: 1))
        .accessibilityElement()
        .accessibilityValue("\(Int((min(max(fraction, 0), 1) * 100).rounded())) percent")
    }
}
