import SwiftUI

private struct PanelSnapshotKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// When true, AppKit-backed controls draw as plain SwiftUI so `ImageRenderer` snapshots show them.
    public var panelSnapshot: Bool {
        get { self[PanelSnapshotKey.self] }
        set { self[PanelSnapshotKey.self] = newValue }
    }
}

/// A recessed search field with a magnifier and a shortcut hint on the right.
public struct Field: View {
    @Binding private var text: String
    /// Placeholder text, e.g. "Search 142 clips".
    public var prompt: String
    /// Shortcut hint, e.g. "⌘F".
    public var shortcut: String?

    @Environment(\.panelTheme) private var theme
    @Environment(\.panelSnapshot) private var snapshot

    /// Creates a search field.
    public init(text: Binding<String>, prompt: String, shortcut: String? = nil) {
        self._text = text
        self.prompt = prompt
        self.shortcut = shortcut
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11.5, weight: .medium))
                .frame(width: 13, height: 13)
                .accessibilityHidden(true)
            Group {
                if snapshot {
                    Text(text.isEmpty ? prompt : text)
                        .foregroundStyle(text.isEmpty ? theme.sub : theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TextField(prompt, text: $text)
                        .textFieldStyle(.plain)
                        .foregroundStyle(theme.ink)
                }
            }
            .font(PanelFont.body(12.5))
            .lineLimit(1)
            if let shortcut {
                Text(shortcut)
                    .font(PanelFont.body(11))
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(theme.sub)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.field)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(theme.line, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(LinearGradient(colors: [.black.opacity(0.08), .clear], startPoint: .top, endPoint: .center), lineWidth: 1)
                )
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}
