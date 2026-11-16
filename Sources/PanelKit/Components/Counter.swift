import SwiftUI

/// Tape-counter drum digits in a chrome frame.
public struct DrumDigits: View {
    /// The digits shown, e.g. "0142". Any characters are drawn one per drum.
    public var digits: String
    /// Draws the small drum.
    public var isSmall: Bool

    /// Creates drum digits.
    public init(_ digits: String, small: Bool = false) {
        self.digits = digits
        self.isSmall = small
    }

    public var body: some View {
        let width: CGFloat = isSmall ? 13 : 20
        let height: CGFloat = isSmall ? 18 : 28
        HStack(spacing: 2) {
            ForEach(Array(digits.enumerated()), id: \.offset) { _, character in
                Text(String(character))
                    .font(PanelFont.condensed(isSmall ? 12.5 : 19, .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color(hex: 0xECEBE6))
                    .frame(width: width, height: height)
                    .background(Color(hex: 0x161616))
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(0.6), location: 0),
                                .init(color: .clear, location: 0.3),
                                .init(color: .clear, location: 0.7),
                                .init(color: .black.opacity(0.6), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(colors: [Color(hex: 0xF2F2F2), Color(hex: 0x9FA1A3)], startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(.black.opacity(0.3), lineWidth: 1))
        )
        .accessibilityElement()
        .accessibilityLabel(digits)
    }
}

/// A drum counter with an uppercase caption and a sentence beside it (On Hand's clips, Disk Forecast's days).
public struct Counter: View {
    /// The digits on the drum.
    public var digits: String
    /// Uppercase caption, e.g. "Clips kept".
    public var title: String
    /// Sentence under the caption.
    public var message: String?
    /// Draw the message in the stop colour.
    public var messageIsAlarm: Bool

    @Environment(\.panelTheme) private var theme

    /// Creates a counter.
    public init(_ digits: String, title: String, message: String? = nil, messageIsAlarm: Bool = false) {
        self.digits = digits
        self.title = title
        self.message = message
        self.messageIsAlarm = messageIsAlarm
    }

    public var body: some View {
        HStack(spacing: 12) {
            DrumDigits(digits)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .panelCaps(10.5, tracking: 0.22)
                    .foregroundStyle(theme.ink2)
                if let message {
                    Text(message)
                        .font(PanelFont.body(12, messageIsAlarm ? .semibold : .regular))
                        .foregroundStyle(messageIsAlarm ? theme.stop : theme.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
