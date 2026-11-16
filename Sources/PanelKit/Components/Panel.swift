import SwiftUI

/// The 340 pt popover container: matte body, 12 pt corners, light or dark following the colour scheme, footer at the bottom.
public struct Panel<Content: View, FooterContent: View>: View {
    /// Popover width in points.
    public static var width: CGFloat { 340 }

    /// The app accent used for pilot lights and projections.
    public var accent: Color
    /// Fill the height the window offers, with the footer pinned to the bottom, instead of hugging the content.
    public var fillsHeight: Bool
    private let content: Content
    private let footer: FooterContent

    @Environment(\.panelTheme) private var theme

    /// Creates a panel with content (usually a `Fascia` first) and a footer slot (usually a `Footer`).
    /// Pass `fillsHeight: true` for a fixed-height window; give scrolling content a `ScrollView` so it takes the slack.
    public init(
        accent: Color,
        fillsHeight: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> FooterContent
    ) {
        self.accent = accent
        self.fillsHeight = fillsHeight
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            if fillsHeight {
                Spacer(minLength: 0)
            }
            footer
        }
        .frame(width: Self.width, alignment: .top)
        .frame(maxHeight: fillsHeight ? .infinity : nil, alignment: .top)
        .fixedSize(horizontal: false, vertical: !fillsHeight)
        .background(theme.background)
        .foregroundStyle(theme.ink)
        .font(PanelFont.body(13))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .environment(\.panelAccent, accent)
    }
}

extension Panel where FooterContent == EmptyView {
    /// Creates a panel with no footer.
    public init(accent: Color, fillsHeight: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(accent: accent, fillsHeight: fillsHeight, content: content, footer: { EmptyView() })
    }
}
