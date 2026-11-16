import SwiftUI

/// A button style for popover actions: black primary, a light metal key for secondary, or red for destructive.
public struct PanelButtonStyle: ButtonStyle {
    /// Visual weight of the button.
    public enum Kind: Sendable {
        /// Solid black (light grey in dark appearance).
        case primary
        /// Metal key with an edge.
        case secondary
        /// Red key for the action that stops, quits or deletes something.
        case destructive
    }

    /// Button size.
    public enum Size: Sendable {
        /// 12.5 pt label, for action bars and dialogs.
        case regular
        /// 11.5 pt label, for keys inside rows and headers (Refresh, Test, Update…).
        case compact
    }

    /// The button's weight.
    public var kind: Kind
    /// The button's size.
    public var size: Size
    /// Stretch to fill the available width.
    public var isWide: Bool

    /// Creates the style.
    public init(_ kind: Kind = .secondary, size: Size = .regular, wide: Bool = false) {
        self.kind = kind
        self.size = size
        self.isWide = wide
    }

    public func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, kind: kind, size: size, isWide: isWide)
    }

    private struct StyledButton: View {
        let configuration: Configuration
        let kind: Kind
        let size: Size
        let isWide: Bool
        @Environment(\.panelTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        private var compact: Bool { size == .compact }

        private var ink: Color {
            switch kind {
            case .primary: theme.buttonInk
            case .secondary: theme.ink
            case .destructive: .white
            }
        }

        var body: some View {
            configuration.label
                .font(PanelFont.body(compact ? 11.5 : 12.5, .semibold))
                .lineLimit(1)
                .foregroundStyle(ink)
                .padding(.vertical, compact ? 3.5 : 8)
                .padding(.horizontal, compact ? 8 : 12)
                .frame(maxWidth: isWide ? .infinity : nil)
                .background {
                    let shape = RoundedRectangle(cornerRadius: compact ? 4 : 5)
                    switch kind {
                    case .primary:
                        shape.fill(theme.button)
                    case .secondary:
                        shape.fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
                            .overlay(shape.strokeBorder(theme.button2Edge, lineWidth: 1))
                    case .destructive:
                        shape.fill(theme.stop)
                            .overlay(shape.strokeBorder(.black.opacity(0.2), lineWidth: 1))
                    }
                }
                .shadow(color: .black.opacity(0.08), radius: 0, y: 1)
                .opacity(configuration.isPressed ? 0.8 : (isEnabled ? 1 : 0.5))
                .contentShape(Rectangle())
                .fixedSize(horizontal: !isWide, vertical: false)
        }
    }
}

extension ButtonStyle where Self == PanelButtonStyle {
    /// The black primary key.
    public static var panelPrimary: PanelButtonStyle { PanelButtonStyle(.primary) }
    /// The metal secondary key.
    public static var panelSecondary: PanelButtonStyle { PanelButtonStyle(.secondary) }
    /// A compact metal key for rows and headers.
    public static var panelCompact: PanelButtonStyle { PanelButtonStyle(.secondary, size: .compact) }
    /// The red destructive key.
    public static var panelDestructive: PanelButtonStyle { PanelButtonStyle(.destructive) }
}

/// An action shown in an `ActionBar`.
public struct PanelAction {
    /// Button title.
    public var title: String
    /// Called when the button is pressed.
    public var perform: () -> Void

    /// Creates an action.
    public init(_ title: String, perform: @escaping () -> Void) {
        self.title = title
        self.perform = perform
    }
}

/// A row of actions: a wide black primary button and an optional secondary button.
public struct ActionBar: View {
    /// The main action.
    public var primary: PanelAction
    /// An optional second action on the right.
    public var secondary: PanelAction?

    /// Creates an action bar.
    public init(primary: PanelAction, secondary: PanelAction? = nil) {
        self.primary = primary
        self.secondary = secondary
    }

    public var body: some View {
        HStack(spacing: 8) {
            Button(primary.title, action: primary.perform)
                .buttonStyle(PanelButtonStyle(.primary, wide: true))
            if let secondary {
                Button(secondary.title, action: secondary.perform)
                    .buttonStyle(PanelButtonStyle(.secondary))
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 14)
    }
}
