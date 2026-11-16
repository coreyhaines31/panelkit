import SwiftUI

/// A text-link button style: link blue for ways out (guides, windows), or quiet underlined ink for small
/// in-place actions (Ignore, Compare).
public struct PanelLinkStyle: ButtonStyle {
    /// How loud the link is.
    public enum Tone: Sendable {
        /// The theme's link colour.
        case accent
        /// Secondary ink, underlined.
        case quiet
    }

    /// The link's tone.
    public var tone: Tone

    /// Creates the style.
    public init(_ tone: Tone = .accent) {
        self.tone = tone
    }

    public func makeBody(configuration: Configuration) -> some View {
        Label(configuration: configuration, tone: tone)
    }

    private struct Label: View {
        let configuration: Configuration
        let tone: Tone
        @Environment(\.panelTheme) private var theme

        var body: some View {
            Group {
                switch tone {
                case .accent:
                    configuration.label
                        .foregroundStyle(theme.link)
                case .quiet:
                    configuration.label
                        .fontWeight(.medium)
                        .foregroundStyle(theme.ink2)
                        .underline(true, color: theme.ink2.opacity(0.4))
                }
            }
            .opacity(configuration.isPressed ? 0.6 : 1)
            .contentShape(Rectangle())
        }
    }
}

extension ButtonStyle where Self == PanelLinkStyle {
    /// A link in the theme's link colour.
    public static var panelLink: PanelLinkStyle { PanelLinkStyle(.accent) }
    /// A quiet underlined link in secondary ink.
    public static var panelQuietLink: PanelLinkStyle { PanelLinkStyle(.quiet) }
}

/// A row of text links at the row inset, e.g. "Usage page · Status · Docs".
public struct LinkBar<Content: View>: View {
    private let content: Content

    /// Creates a link bar from buttons; they get `PanelLinkStyle` unless they set their own style.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 14) {
            content
                .fixedSize()
            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .buttonStyle(PanelLinkStyle(.accent))
        .font(PanelFont.body(12))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}
