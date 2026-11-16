import SwiftUI

/// Fonts used by the Brushed panel: Barlow Semi Condensed for plates and strips, SF Pro for body text.
public enum PanelFont {
    /// A Barlow Semi Condensed weight.
    public enum Weight: String, Sendable {
        case light = "BarlowSemiCondensed-Light"
        case medium = "BarlowSemiCondensed-Medium"
        case semibold = "BarlowSemiCondensed-SemiBold"
        case bold = "BarlowSemiCondensed-Bold"
    }

    /// Barlow Semi Condensed at a point size (call `PanelKit.registerFonts()` first).
    public static func condensed(_ size: CGFloat, _ weight: Weight = .semibold) -> Font {
        .custom(weight.rawValue, size: size)
    }

    /// The system font (SF Pro) at a point size.
    public static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

extension Text {
    /// Uppercase condensed caps with CSS-style em tracking, as used by plates, strips and section labels.
    func panelCaps(_ size: CGFloat, tracking em: CGFloat, weight: PanelFont.Weight = .semibold) -> some View {
        self.font(PanelFont.condensed(size, weight))
            .tracking(size * em)
            .textCase(.uppercase)
    }
}
