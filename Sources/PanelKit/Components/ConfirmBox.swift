import SwiftUI

/// An inline confirmation for an action that stops, quits or deletes something: the consequence,
/// an optional warning, Cancel (Esc) and a red action key. It has no outer padding.
public struct ConfirmBox: View {
    /// Optional bold first line.
    public var title: String?
    /// What will happen.
    public var message: String
    /// An extra caution line, e.g. "Unsaved work in 2 tabs".
    public var warning: String?
    /// The red key's title, e.g. "Quit Chrome".
    public var actionTitle: String
    /// Disables the red key (e.g. while working).
    public var isActionDisabled: Bool
    private let cancel: () -> Void
    private let confirm: () -> Void

    @Environment(\.panelTheme) private var theme

    /// Creates a confirm box. Cancel also answers Esc.
    public init(
        title: String? = nil,
        message: String,
        warning: String? = nil,
        actionTitle: String,
        isActionDisabled: Bool = false,
        cancel: @escaping () -> Void,
        confirm: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.warning = warning
        self.actionTitle = actionTitle
        self.isActionDisabled = isActionDisabled
        self.cancel = cancel
        self.confirm = confirm
    }

    public var body: some View {
        Recess {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    Text(title)
                        .font(PanelFont.body(13, .semibold))
                        .foregroundStyle(theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(message)
                    .font(PanelFont.body(12))
                    .foregroundStyle(theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let warning {
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(PanelFont.body(12, .medium))
                        .foregroundStyle(theme.caution)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Button("Cancel", action: cancel)
                        .buttonStyle(PanelButtonStyle(.secondary, size: .compact))
                        .keyboardShortcut(.cancelAction)
                    Spacer(minLength: 8)
                    Button(actionTitle, role: .destructive, action: confirm)
                        .buttonStyle(PanelButtonStyle(.destructive, size: .compact))
                        .disabled(isActionDisabled)
                }
                .padding(.top, 2)
            }
        }
    }
}
