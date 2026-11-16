import SwiftUI

/// An outlined strip like the fascia's detail strip, but for a full sentence that wraps, with an icon.
/// It has no outer padding; it usually sits inside a `Fascia` under the instrument.
public struct TipStrip: View {
    /// The sentence.
    public var text: String
    /// The SF Symbol before it.
    public var systemImage: String
    /// What VoiceOver says before the text, e.g. "Framing tip".
    public var accessibilityPrefix: String?

    @Environment(\.panelTheme) private var theme

    /// Creates a tip strip.
    public init(_ text: String, systemImage: String = "lightbulb", accessibilityPrefix: String? = nil) {
        self.text = text
        self.systemImage = systemImage
        self.accessibilityPrefix = accessibilityPrefix
    }

    public var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: systemImage)
        }
        .font(PanelFont.body(11, .medium))
        .foregroundStyle(theme.ink2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Rectangle().strokeBorder(theme.stripOutline, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityPrefix.map { "\($0): \(text)" } ?? text)
    }
}
