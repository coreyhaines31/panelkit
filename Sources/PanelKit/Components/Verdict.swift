import SwiftUI

/// A bare status LED (7 pt lamp with a glow), for inline status next to your own text.
/// It is hidden from VoiceOver: say the status in the text beside it.
public struct StatusLED: View {
    /// The status the LED shows.
    public var status: PanelStatus
    /// Diameter in points.
    public var size: CGFloat

    @Environment(\.panelTheme) private var theme

    /// Creates a status LED.
    public init(_ status: PanelStatus, size: CGFloat = 7) {
        self.status = status
        self.size = size
    }

    public var body: some View {
        let color = theme.color(for: status)
        Circle()
            .fill(color)
            .overlay(
                Circle().fill(
                    LinearGradient(colors: [.clear, .black.opacity(0.3)], startPoint: .center, endPoint: .bottom)
                )
            )
            .frame(width: size, height: size)
            .lampGlow(status == .off ? .clear : color, radius: size * 5 / 7)
            .accessibilityHidden(true)
    }
}

/// A status LED with an uppercase word beside it. Colour is always paired with a word.
public struct StatusLight: View {
    /// The status the LED shows.
    public var status: PanelStatus
    /// The word beside the LED, e.g. "On pace".
    public var label: String

    @Environment(\.panelTheme) private var theme

    /// Creates a status light.
    public init(_ status: PanelStatus, _ label: String) {
        self.status = status
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 6) {
            StatusLED(status)
            Text(label)
                .panelCaps(10, tracking: 0.2)
                .foregroundStyle(theme.ink2)
                .lineLimit(1)
                .fixedSize()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(status.spokenName)
    }
}

extension PanelStatus {
    /// Words VoiceOver reads for the status colour.
    var spokenName: String {
        switch self {
        case .go: "Good"
        case .caution: "Caution"
        case .stop: "Problem"
        case .off: "Off"
        }
    }
}

/// The verdict under the fascia: an optional status light, a bold condensed title and a sentence.
public struct Verdict: View {
    /// Optional status light above the title.
    public var status: PanelStatus?
    /// The status light's word.
    public var statusLabel: String?
    /// The headline, e.g. "Makes it to reset".
    public var title: String
    /// One or two sentences of explanation.
    public var message: String?

    @Environment(\.panelTheme) private var theme

    /// Creates a verdict.
    public init(_ title: String, message: String? = nil, status: PanelStatus? = nil, statusLabel: String? = nil) {
        self.title = title
        self.message = message
        self.status = status
        self.statusLabel = statusLabel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let status, let statusLabel {
                StatusLight(status, statusLabel)
                    .padding(.bottom, 1)
            }
            Text(title)
                .font(PanelFont.condensed(23, .semibold))
                .foregroundStyle(theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let message {
                Text(message)
                    .font(PanelFont.body(12))
                    .foregroundStyle(theme.sub)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
