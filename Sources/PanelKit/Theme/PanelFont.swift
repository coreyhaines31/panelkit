import AppKit
import SwiftUI

final class FontAvailability: @unchecked Sendable {
    static let shared = FontAvailability()
    private let lock = NSLock()
    private var names: Set<String> = []

    func isKnown(_ name: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return names.contains(name)
    }

    func remember(_ name: String) {
        lock.lock()
        defer { lock.unlock() }
        names.insert(name)
    }
}

/// Fonts used by the Brushed panel: Barlow Semi Condensed for plates and strips, SF Pro for body text.
public enum PanelFont {
    /// A Barlow Semi Condensed weight.
    public enum Weight: String, Sendable {
        case light = "BarlowSemiCondensed-Light"
        case medium = "BarlowSemiCondensed-Medium"
        case semibold = "BarlowSemiCondensed-SemiBold"
        case bold = "BarlowSemiCondensed-Bold"

        var systemWeight: Font.Weight {
            switch self {
            case .light: .light
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }

        /// Whether the face is registered; only a positive answer is cached, so registering later still takes effect.
        var isAvailable: Bool {
            if FontAvailability.shared.isKnown(rawValue) { return true }
            guard NSFont(name: rawValue, size: 12) != nil else { return false }
            FontAvailability.shared.remember(rawValue)
            return true
        }
    }

    /// Barlow Semi Condensed at a point size (call `PanelKit.registerFonts()` first).
    /// Falls back to the condensed system font when the bundled faces aren't registered.
    public static func condensed(_ size: CGFloat, _ weight: Weight = .semibold) -> Font {
        if weight.isAvailable {
            return .custom(weight.rawValue, size: size)
        }
        return .system(size: size, weight: weight.systemWeight).width(.condensed)
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
