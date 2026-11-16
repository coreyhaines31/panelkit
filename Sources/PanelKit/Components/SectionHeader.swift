import SwiftUI

/// A section divider: hairline above, an uppercase condensed label on the left, optional detail on the right.
public struct SectionHeader: View {
    /// The section label, e.g. "Claude Code".
    public var title: String
    /// Right-hand detail, e.g. "Max plan".
    public var detail: String?
    private var trailing: AnyView?

    @Environment(\.panelTheme) private var theme

    /// Creates a section header.
    public init(_ title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    /// Creates a section header with a link-coloured action on the right, e.g. "Open Forecast…".
    public init(_ title: String, actionTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.detail = nil
        self.trailing = AnyView(
            Button(actionTitle, action: action)
                .buttonStyle(PanelLinkStyle(.accent))
                .font(PanelFont.body(11, .medium))
        )
    }

    /// Replaces the detail with views on the right (a link, a compact key).
    public func trailingAccessory<V: View>(@ViewBuilder _ accessory: () -> V) -> SectionHeader {
        var copy = self
        copy.trailing = AnyView(accessory())
        return copy
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .panelCaps(10, tracking: 0.2)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            if let trailing {
                trailing
                    .lineLimit(1)
                    .fixedSize()
            } else if let detail {
                Text(detail)
                    .font(PanelFont.body(11, .medium))
                    .tracking(11 * 0.04)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(theme.sub)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .padding(.horizontal, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.line).frame(height: 1)
        }
    }
}
