import AppKit
import SwiftUI

/// The appearance a `MenuCard` draws in.
public enum MenuCardAppearance: Sendable {
    /// Light or dark following the menu's colour scheme.
    case automatic
    /// Always black anodised, e.g. Midnight Oil's night instrument.
    case dark
}

/// The Brushed card at the top of a native `NSMenu`: a matte card inset 5 pt from the menu's edges
/// (330 pt in the default 340 pt menu), with 7 pt corners and a hairline ring. Put a `Fascia`, `Verdict`
/// and rows inside, as in a `Panel`. Pass `menuWidth` when the menu is wider, so the card fills it.
public struct MenuCard<Content: View>: View {
    /// The default menu width the card is inset in.
    public static var menuWidth: CGFloat { 340 }
    /// Inset from the menu's edges.
    public static var inset: CGFloat { 5 }
    /// The card's own width in the default menu.
    public static var width: CGFloat { menuWidth - inset * 2 }

    /// The app accent used for pilot lights and projections.
    public var accent: Color
    /// Light or dark.
    public var appearance: MenuCardAppearance
    /// The width of the menu the card sits in; the card is this minus the inset on each side.
    public var menuWidth: CGFloat
    private let content: Content

    @Environment(\.panelTheme) private var environmentTheme

    /// Creates a menu card.
    public init(
        accent: Color,
        appearance: MenuCardAppearance = .automatic,
        menuWidth: CGFloat = MenuCard<EmptyView>.menuWidth,
        @ViewBuilder content: () -> Content
    ) {
        self.accent = accent
        self.appearance = appearance
        self.menuWidth = max(menuWidth, Self.inset * 2 + 120)
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
        .frame(width: menuWidth - Self.inset * 2, alignment: .leading)
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
    /// A menu item that hosts a SwiftUI view (usually a `MenuCard`), sized to fit. On macOS 26 and
    /// later it also backs the menu with a solid colour, so the rows under the card don't show the
    /// windows behind the menu through the system's glass.
    @MainActor
    public static func panelCard<V: View>(_ view: V) -> NSMenuItem {
        let host = MenuCardHostingView(rootView: view)
        host.setFrameSize(host.fittingSize)
        host.autoresizingMask = [.width]
        let item = NSMenuItem()
        item.view = host
        return item
    }
}

/// Hosts the card and keeps the menu's solid backing in whichever menu window the card is in.
private final class MenuCardHostingView<Content: View>: NSHostingView<Content> {
    private weak var backing: MenuBackingView?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        backing?.removeFromSuperview()
        if #available(macOS 26, *), let window {
            backing = MenuBackingView.install(in: window)
        }
    }
}

/// A solid fill between the menu window's glass and its rows. AppKit has no API for a menu's
/// background, so this sits at the bottom of the menu window's content view.
private final class MenuBackingView: NSView {
    /// The corner radius macOS 26 gives a menu.
    private static let cornerRadius: CGFloat = 12

    private static let fill = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(srgbRed: 0.137, green: 0.137, blue: 0.145, alpha: 1)
            : NSColor(srgbRed: 0.965, green: 0.965, blue: 0.961, alpha: 1)
    }

    static func install(in window: NSWindow) -> MenuBackingView? {
        guard let content = window.contentView else { return nil }
        let backing = MenuBackingView(frame: content.bounds)
        backing.autoresizingMask = [.width, .height]
        content.addSubview(backing, positioned: .below, relativeTo: nil)
        return backing
    }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        layer?.cornerRadius = Self.cornerRadius
        layer?.cornerCurve = .continuous
        layer?.backgroundColor = Self.fill.cgColor
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
