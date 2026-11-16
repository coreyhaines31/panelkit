import SwiftUI

/// The black nameplate at the top of the fascia: a pilot light in the app accent and an uppercase label.
public struct Nameplate: View {
    /// The label text, e.g. "FUEL".
    public var label: String
    /// Whether the pilot light is lit.
    public var isLit: Bool

    @Environment(\.panelTheme) private var theme
    @Environment(\.panelAccent) private var accent

    /// Creates a nameplate with a lit pilot light in the environment's accent.
    public init(_ label: String, isLit: Bool = true) {
        self.label = label
        self.isLit = isLit
    }

    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isLit ? accent : Color(hex: 0x8C8E90))
                .frame(width: 6, height: 6)
                .lampGlow(isLit ? accent : .clear, radius: 5)
            Text(label)
                .panelCaps(10.5, tracking: 0.26)
                .foregroundStyle(theme.plateInk)
                .lineLimit(1)
        }
        .padding(.leading, 8)
        .padding(.trailing, 9)
        .padding(.vertical, 5)
        .background(theme.plate, in: RoundedRectangle(cornerRadius: 1.5))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}
