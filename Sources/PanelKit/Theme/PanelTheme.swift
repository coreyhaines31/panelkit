import SwiftUI

extension Color {
    /// Creates a colour from a 0xRRGGBB value.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// A status a light, tape or value can show. Colour is reserved for these.
public enum PanelStatus: String, Sendable, CaseIterable {
    case go
    case caution
    case stop
    case off
}

/// Colour tokens for the Brushed popover in one appearance.
public struct PanelTheme: Sendable {
    /// Popover body behind the matte rows.
    public var background: Color
    /// Primary text.
    public var ink: Color
    /// Secondary text on metal (timestamps, strip outlines, light labels).
    public var ink2: Color
    /// Subtitles, section labels and footer text.
    public var sub: Color
    /// Hairline dividers.
    public var line: Color
    /// Recessed field and selected-row fill.
    public var field: Color
    /// Empty tape and switch track.
    public var track: Color
    /// Filled tape (graphite).
    public var fill: Color
    /// Primary button fill.
    public var button: Color
    /// Primary button text.
    public var buttonInk: Color
    /// Secondary button gradient, top to bottom.
    public var button2: [Color]
    /// Secondary button and icon tile edge.
    public var button2Edge: Color
    /// Reversed label plate fill (nameplate, main strip).
    public var plate: Color
    /// Reversed label plate text.
    public var plateInk: Color
    /// Outline of the detail strip above the main strip.
    public var stripOutline: Color
    /// Switch track when on.
    public var switchOn: Color
    /// Fascia top highlight line.
    public var fasciaHighlight: Color
    /// Fascia bottom edge.
    public var fasciaEdge: Color
    /// Go status colour.
    public var go: Color
    /// Caution status colour.
    public var caution: Color
    /// Stop status colour (also out-of-range values).
    public var stop: Color
    /// Whether the fascia is black anodised (dark) rather than brushed aluminium.
    public var isDark: Bool

    /// Colour for a status.
    public func color(for status: PanelStatus) -> Color {
        switch status {
        case .go: go
        case .caution: caution
        case .stop: stop
        case .off: Color(hex: 0x8C8E90)
        }
    }

    /// Brushed aluminium (light appearance).
    public static let light = PanelTheme(
        background: Color(hex: 0xEEEEED),
        ink: Color(hex: 0x161616),
        ink2: Color(hex: 0x3D3F41),
        sub: Color(hex: 0x66686A),
        line: Color(hex: 0xDCDCDB),
        field: Color(hex: 0xF8F8F7),
        track: Color(hex: 0xD6D7D7),
        fill: Color(hex: 0x2C2C2D),
        button: Color(hex: 0x1B1B1B),
        buttonInk: Color(hex: 0xE3E4E5),
        button2: [Color(hex: 0xF7F7F7), Color(hex: 0xD9DADB)],
        button2Edge: Color(hex: 0x9C9EA0),
        plate: Color(hex: 0x1B1B1B),
        plateInk: Color(hex: 0xD8D9DA),
        stripOutline: Color(hex: 0x1B1B1B),
        switchOn: Color(hex: 0x1B1B1B),
        fasciaHighlight: Color.white.opacity(0.55),
        fasciaEdge: Color.black.opacity(0.25),
        go: Color(hex: 0x2F9E4F),
        caution: Color(hex: 0xD9921A),
        stop: Color(hex: 0xE0452B),
        isDark: false
    )

    /// Black anodised (dark appearance).
    public static let dark = PanelTheme(
        background: Color(hex: 0x161617),
        ink: Color(hex: 0xE6E7E8),
        ink2: Color(hex: 0xC6C7C8),
        sub: Color(hex: 0x9A9C9E),
        line: Color(hex: 0x2A2A2C),
        field: Color(hex: 0x0F0F10),
        track: Color(hex: 0x2E2E30),
        fill: Color(hex: 0xD0D1D2),
        button: Color(hex: 0xD6D7D8),
        buttonInk: Color(hex: 0x161616),
        button2: [Color(hex: 0x333436), Color(hex: 0x232425)],
        button2Edge: Color(hex: 0x4A4C4E),
        plate: Color(hex: 0xC9CBCC),
        plateInk: Color(hex: 0x161616),
        stripOutline: Color(hex: 0x6A6C6E),
        switchOn: Color(hex: 0x8F9193),
        fasciaHighlight: Color.white.opacity(0.08),
        fasciaEdge: Color.black,
        go: Color(hex: 0x4FD06F),
        caution: Color(hex: 0xF2B23A),
        stop: Color(hex: 0xFF5A3C),
        isDark: true
    )

    /// The theme for a colour scheme.
    public static func resolve(_ scheme: ColorScheme) -> PanelTheme {
        scheme == .dark ? .dark : .light
    }
}

/// App accent colours. Each app's accent appears only as its nameplate pilot light.
public enum PanelAccent {
    /// Fuel Gauge orange.
    public static let fuelGauge = Color(hex: 0xE06A1B)
    /// Spare teal.
    public static let spare = Color(hex: 0x11857C)
    /// Disk Forecast blue.
    public static let diskForecast = Color(hex: 0x2F63D3)
    /// Midnight Oil indigo (lifted for the black fascia).
    public static let midnightOil = Color(hex: 0x7A74FF)
    /// WiFi or ISP cyan.
    public static let wifiOrISP = Color(hex: 0x0B8FB3)
    /// Green Room violet.
    public static let greenRoom = Color(hex: 0x8448C9)
    /// On Hand magenta.
    public static let onHand = Color(hex: 0xB43A9E)
    /// Coat Check raspberry.
    public static let coatCheck = Color(hex: 0xC4366F)
}

private struct PanelAccentKey: EnvironmentKey {
    static let defaultValue = Color(hex: 0xE0452B)
}

private struct PanelThemeOverrideKey: EnvironmentKey {
    static let defaultValue: PanelTheme? = nil
}

extension EnvironmentValues {
    /// The app accent used for pilot lights.
    public var panelAccent: Color {
        get { self[PanelAccentKey.self] }
        set { self[PanelAccentKey.self] = newValue }
    }

    /// An explicit theme; when nil, components follow `colorScheme`.
    public var panelThemeOverride: PanelTheme? {
        get { self[PanelThemeOverrideKey.self] }
        set { self[PanelThemeOverrideKey.self] = newValue }
    }

    /// The theme components draw with.
    var panelTheme: PanelTheme {
        panelThemeOverride ?? PanelTheme.resolve(colorScheme)
    }
}

extension View {
    /// Sets the app accent (pilot light colour) for PanelKit views inside.
    public func panelAccent(_ color: Color) -> some View {
        environment(\.panelAccent, color)
    }
}
