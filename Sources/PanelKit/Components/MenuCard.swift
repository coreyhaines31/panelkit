import AppKit
import SwiftUI

/// The appearance a `MenuCard` draws in.
public enum MenuCardAppearance: Sendable {
    /// Light or dark following the menu's colour scheme.
    case automatic
    /// Always black anodised, e.g. Midnight Oil's night instrument.
    case dark
}

/// The Brushed card at the top of a native `NSMenu`: a 330 pt matte card inset 5 pt in a 340 pt menu,
/// with 7 pt corners and a hairline ring. Put a `Fascia`, `Verdict` and rows inside, as in a `Panel`.
public struct MenuCard<Content: View>: View {
    /// The menu width the card is inset in.
    public static var menuWidth: CGFloat { 340 }
    /// Inset from the menu's edges.
    public static var inset: CGFloat { 5 }
    /// The card's own width.
    public static var width: CGFloat { menuWidth - inset * 2 }

    /// The app accent used for pilot lights and projections.
    public var accent: Color
    /// Light or dark.
    public var appearance: MenuCardAppearance
    private let content: Content

    @Environment(\.panelTheme) private var environmentTheme

    /// Creates a menu card.
    public init(accent: Color, appearance: MenuCardAppearance = .automatic, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.appearance = appearance
        self.content = content()
    }

    private var theme: PanelTheme {
        appearance == .dark ? .dark : environmentTheme
    }

    public var body: some View {
        let theme = theme
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(width: Self.width, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(theme.background)
        .foregroundStyle(theme.ink)
        .font(PanelFont.body(13))
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.black.opacity(theme.isDark ? 0.5 : 0.12), lineWidth: 1))
        .padding(.horizontal, Self.inset)
        .padding(.top, 1)
        .padding(.bottom, Self.inset)
        .environment(\.panelThemeOverride, theme)
        .environment(\.colorScheme, theme.isDark ? .dark : .light)
        .environment(\.panelAccent, accent)
    }
}

extension NSMenuItem {
    /// A menu item that hosts a SwiftUI view (usually a `MenuCard`), sized to fit.
    @MainActor
    public static func panelCard<V: View>(_ view: V) -> NSMenuItem {
        let host = NSHostingView(rootView: view)
        host.setFrameSize(host.fittingSize)
        let item = NSMenuItem()
        item.view = host
        return item
    }
}
