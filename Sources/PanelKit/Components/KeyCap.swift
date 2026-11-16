import SwiftUI

/// A 20 pt metal key with an SF Symbol, for toolbar keys in the fascia (back, pause, settings).
public struct KeyCap: View {
    /// The SF Symbol name.
    public var systemImage: String
    /// What VoiceOver reads, e.g. "Back".
    public var accessibilityLabel: String
    private let action: () -> Void

    /// Creates a key that runs `action` when pressed.
    public init(_ systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .buttonStyle(KeyCapStyle())
        .accessibilityLabel(accessibilityLabel)
        .help(accessibilityLabel)
    }
}

/// The button style behind `KeyCap`, for keys whose label isn't a single symbol.
public struct KeyCapStyle: ButtonStyle {
    /// Creates the style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Face(configuration: configuration)
    }

    private struct Face: View {
        let configuration: Configuration
        @Environment(\.panelTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: 4)
            configuration.label
                .font(.system(size: 9.5, weight: .bold))
                .foregroundStyle(theme.isDark ? theme.ink : Color(hex: 0x2C2C2D))
                .frame(minWidth: 20, minHeight: 20)
                .background {
                    if theme.isDark {
                        shape.fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
                            .overlay(shape.strokeBorder(theme.button2Edge, lineWidth: 1))
                    } else {
                        shape.fill(.white.opacity(0.45))
                            .overlay(shape.strokeBorder(.black.opacity(0.15), lineWidth: 1))
                    }
                }
                .opacity(configuration.isPressed ? 0.7 : (isEnabled ? 1 : 0.45))
                .contentShape(shape)
        }
    }
}
