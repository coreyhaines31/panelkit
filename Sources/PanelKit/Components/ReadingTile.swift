import SwiftUI

/// A small stat tile: a caps label over a value and an optional line or tape, in a recess.
/// Lay two side by side with `HStack(spacing: 8)` or a two-column grid inside `.padding(.horizontal, 14)`.
public struct ReadingTile<Detail: View>: View {
    /// The caps label, e.g. "Memory".
    public var label: String
    /// The reading, e.g. "12.4 GB".
    public var value: String?
    /// Tints the value and the tile in a status colour.
    public var status: PanelStatus?
    private let detail: Detail

    @Environment(\.panelTheme) private var theme

    /// Creates a tile with detail below the value (a `Text`, a `Tape`).
    public init(_ label: String, value: String? = nil, status: PanelStatus? = nil, @ViewBuilder detail: () -> Detail) {
        self.label = label
        self.value = value
        self.status = status
        self.detail = detail()
    }

    public var body: some View {
        Recess(tint: status, padding: EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .panelCaps(9.5, tracking: 0.18)
                    .foregroundStyle(theme.sub)
                    .lineLimit(1)
                if let value {
                    Text(value)
                        .font(PanelFont.body(12, .semibold))
                        .monospacedDigit()
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                }
                detail
                    .font(PanelFont.body(11))
                    .foregroundStyle(theme.sub)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

extension ReadingTile where Detail == EmptyView {
    /// Creates a tile with a label and value only.
    public init(_ label: String, value: String, status: PanelStatus? = nil) {
        self.init(label, value: value, status: status) { EmptyView() }
    }
}
