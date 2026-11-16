import SwiftUI

/// The footer every popover shares: "Settings… ⌘," on the left and "Quit <App> ⌘Q" on the right.
public struct Footer: View {
    /// The app name in the quit button.
    public var appName: String
    private let openSettings: () -> Void
    private let quit: () -> Void

    @Environment(\.panelTheme) private var theme

    /// Creates a footer. The closures run when the buttons are pressed; keyboard shortcuts are attached too.
    public init(appName: String, openSettings: @escaping () -> Void, quit: @escaping () -> Void) {
        self.appName = appName
        self.openSettings = openSettings
        self.quit = quit
    }

    public var body: some View {
        HStack {
            Button(action: openSettings) {
                label("Settings…", key: "⌘,")
            }
            .keyboardShortcut(",", modifiers: .command)
            .accessibilityLabel("Settings")
            Spacer(minLength: 8)
            Button(action: quit) {
                label("Quit \(appName)", key: "⌘Q")
            }
            .keyboardShortcut("q", modifiers: .command)
            .accessibilityLabel("Quit \(appName)")
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.sub)
        .padding(.top, 9)
        .padding(.bottom, 10)
        .padding(.horizontal, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.line).frame(height: 1)
        }
    }

    private func label(_ title: String, key: String) -> some View {
        HStack(spacing: 4) {
            Text(title).font(PanelFont.body(12))
            Text(key).font(PanelFont.body(11)).opacity(0.8)
        }
        .lineLimit(1)
        .contentShape(Rectangle())
    }
}
