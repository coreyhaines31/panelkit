import SwiftUI

/// A caution-tinted card for a problem with its own fix: a bold title, a sentence, and actions
/// (buttons default to `PanelLinkStyle`; give compact keys their own style). Inset to the row margin.
public struct Notice<Actions: View>: View {
    /// The headline, e.g. "Your plan caps speed at 100 Mbps".
    public var title: String
    /// One or two sentences.
    public var message: String?
    /// The tint; caution by default.
    public var status: PanelStatus
    private let actions: Actions

    @Environment(\.panelTheme) private var theme

    /// Creates a notice with actions below the message.
    public init(
        _ title: String,
        message: String? = nil,
        status: PanelStatus = .caution,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.message = message
        self.status = status
        self.actions = actions()
    }

    public var body: some View {
        let color = theme.color(for: status)
        let shape = RoundedRectangle(cornerRadius: 6)
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PanelFont.body(12, .semibold))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let message {
                Text(message)
                    .font(PanelFont.body(11.5))
                    .foregroundStyle(theme.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if Actions.self != EmptyView.self {
                HStack(spacing: 10) { actions }
                    .buttonStyle(PanelLinkStyle(.accent))
                    .font(PanelFont.body(12))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.13), in: shape)
        .overlay(shape.strokeBorder(color.opacity(0.35), lineWidth: 1))
        .padding(EdgeInsets(top: 4, leading: 14, bottom: 10, trailing: 14))
    }
}

extension Notice where Actions == EmptyView {
    /// Creates a notice with no actions.
    public init(_ title: String, message: String? = nil, status: PanelStatus = .caution) {
        self.init(title, message: message, status: status) { EmptyView() }
    }
}
