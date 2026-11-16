import SwiftUI

/// The label strips under a meter: an optional outlined detail strip above a reversed main strip.
public struct LabelStrips: View {
    /// Text for the outlined detail strip, e.g. "5-hour window".
    public var detail: String?
    /// Text for the reversed main strip, e.g. "Claude Code".
    public var label: String

    @Environment(\.panelTheme) private var theme

    /// Creates label strips; `detail` is drawn in the outlined strip above `label`.
    public init(_ label: String, detail: String? = nil) {
        self.label = label
        self.detail = detail
    }

    public var body: some View {
        VStack(spacing: 3) {
            if let detail {
                Text(detail)
                    .panelCaps(9.5, tracking: 0.24)
                    .foregroundStyle(theme.ink2)
                    .lineLimit(1)
                    .padding(.top, 3)
                    .padding(.bottom, 2)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .overlay(Rectangle().strokeBorder(theme.stripOutline, lineWidth: 1))
            }
            Text(label)
                .panelCaps(11.5, tracking: 0.3)
                .foregroundStyle(theme.plateInk)
                .lineLimit(1)
                .padding(.vertical, 5)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity)
                .background(theme.plate)
        }
        .accessibilityElement(children: .combine)
    }
}
