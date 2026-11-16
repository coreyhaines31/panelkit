import SwiftUI

/// A button style for popover actions: black primary, or a light metal key for secondary.
public struct PanelButtonStyle: ButtonStyle {
    /// Visual weight of the button.
    public enum Kind: Sendable {
        /// Solid black (light grey in dark appearance).
        case primary
        /// Metal key with an edge.
        case secondary
    }

    /// The button's weight.
    public var kind: Kind
    /// Stretch to fill the available width.
    public var isWide: Bool

    /// Creates the style.
    public init(_ kind: Kind = .secondary, wide: Bool = false) {
        self.kind = kind
        self.isWide = wide
    }

    public func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, kind: kind, isWide: isWide)
    }

    private struct StyledButton: View {
        let configuration: Configuration
        let kind: Kind
        let isWide: Bool
        @Environment(\.panelTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(PanelFont.body(12.5, .semibold))
                .lineLimit(1)
                .foregroundStyle(kind == .primary ? theme.buttonInk : theme.ink)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: isWide ? .infinity : nil)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 5)
                    switch kind {
                    case .primary:
                        shape.fill(theme.button)
                    case .secondary:
                        shape.fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
                            .overlay(shape.strokeBorder(theme.button2Edge, lineWidth: 1))
                    }
                }
                .shadow(color: .black.opacity(0.08), radius: 0, y: 1)
                .opacity(configuration.isPressed ? 0.8 : (isEnabled ? 1 : 0.5))
                .contentShape(Rectangle())
        }
    }
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
