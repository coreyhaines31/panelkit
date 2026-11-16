import SwiftUI

/// A section divider: hairline above, an uppercase condensed label on the left, optional detail on the right.
public struct SectionHeader: View {
    /// The section label, e.g. "Claude Code".
    public var title: String
    /// Right-hand detail, e.g. "Max plan".
    public var detail: String?

    @Environment(\.panelTheme) private var theme

    /// Creates a section header.
    public init(_ title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .panelCaps(10, tracking: 0.2)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            if let detail {
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
