import SwiftUI

/// How a row's value is coloured.
public enum RowValueTone: Sendable {
    /// Primary ink.
    case normal
    /// Out of range: stop colour, semibold.
    case hot
}

/// A tape drawn under a row.
public struct RowTape: Sendable {
    /// Filled fraction (0...1).
    public var fraction: Double
    /// Tint; nil keeps graphite.
    public var status: PanelStatus?
    /// Where the level is headed (0...1), drawn faintly past the fill.
    public var projection: Double?

    /// Creates a row tape.
    public init(_ fraction: Double, projection: Double? = nil, status: PanelStatus? = nil) {
        self.fraction = fraction
        self.projection = projection
        self.status = status
    }
}

/// Display states for a row.
public struct RowOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// Recessed field background, for the keyboard-selected row.
    public static let selected = RowOptions(rawValue: 1 << 0)
    /// Faded, for skipped or secondary items.
    public static let dimmed = RowOptions(rawValue: 1 << 1)
    /// A trailing chevron, for rows that open something.
    public static let chevron = RowOptions(rawValue: 1 << 2)
    /// Monospaced name, for code or clipboard text.
    public static let monospacedName = RowOptions(rawValue: 1 << 3)
}

/// A readout row: optional icon, name and subtitle, a value column, and an optional tape.
public struct Row<Icon: View, Accessory: View>: View {
    /// Bold name.
    public var name: String
    /// Secondary line under the name.
    public var subtitle: String?
    /// Main value on the right.
    public var value: String?
    /// Value colouring.
    public var valueTone: RowValueTone
    /// Small line under the value.
    public var secondary: String?
    /// Tape under the row.
    public var tape: RowTape?
    /// Selected, dimmed, chevron and monospaced states.
    public var options: RowOptions
    private let icon: Icon
    private let accessory: Accessory
    private var subtitleLines = 1
    private var trailing: AnyView?

    @Environment(\.panelTheme) private var theme

    /// Creates a row with an icon and a trailing accessory (status light, switch, shortcut) above the value.
    public init(
        _ name: String,
        icon: Icon,
        subtitle: String? = nil,
        value: String? = nil,
        valueTone: RowValueTone = .normal,
        secondary: String? = nil,
        tape: RowTape? = nil,
        options: RowOptions = [],
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.name = name
        self.subtitle = subtitle
        self.value = value
        self.valueTone = valueTone
        self.secondary = secondary
        self.tape = tape
        self.options = options
        self.icon = icon
        self.accessory = accessory()
    }

    public var body: some View {
        let selected = options.contains(.selected)
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                if Icon.self != EmptyView.self {
                    icon.frame(width: 22, height: 22)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(options.contains(.monospacedName)
                              ? .system(size: 11.5, weight: .semibold, design: .monospaced)
                              : PanelFont.body(13, .semibold))
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let subtitle {
                        Text(subtitle)
                            .font(PanelFont.body(11.5))
                            .foregroundStyle(theme.sub)
                            .lineLimit(subtitleLines)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: subtitleLines > 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                valueColumn
                if let trailing {
                    trailing.fixedSize()
                }
                if options.contains(.chevron) {
                    Text("›")
                        .font(PanelFont.body(15))
                        .foregroundStyle(theme.sub)
                        .fixedSize()
                        .accessibilityHidden(true)
                }
            }
            if let tape {
                Tape(tape.fraction, projection: tape.projection, status: tape.status)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, selected ? 8 : 14)
        .background {
            if selected {
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.field)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(theme.line, lineWidth: 1))
            }
        }
        .padding(.horizontal, selected ? 6 : 0)
        .opacity(options.contains(.dimmed) ? 0.55 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    /// Lets the subtitle wrap to this many lines (default 1); pass nil for no limit.
    public func subtitleLineLimit(_ lines: Int?) -> Row {
        var copy = self
        copy.subtitleLines = lines ?? Int.max
        return copy
    }

    /// Puts views (buttons, a switch) at the far right of the row, after the value column.
    public func trailingAccessory<V: View>(@ViewBuilder _ accessory: () -> V) -> Row {
        var copy = self
        copy.trailing = AnyView(accessory())
        return copy
    }

    @ViewBuilder private var valueColumn: some View {
        let hasAccessory = Accessory.self != EmptyView.self
        if hasAccessory || value != nil || secondary != nil {
            VStack(alignment: .trailing, spacing: 4) {
                if hasAccessory {
                    accessory
                }
                if let value {
                    Text(value)
                        .font(PanelFont.body(13, valueTone == .hot ? .semibold : .regular))
                        .monospacedDigit()
                        .foregroundStyle(valueTone == .hot ? theme.stop : theme.ink)
                        .lineLimit(1)
                }
                if let secondary {
                    Text(secondary)
                        .font(PanelFont.body(11))
                        .monospacedDigit()
                        .foregroundStyle(theme.sub)
                        .lineLimit(1)
                }
            }
            .fixedSize()
        }
    }
}

extension Row where Icon == EmptyView, Accessory == EmptyView {
    /// Creates a text-only row.
    public init(
        _ name: String,
        subtitle: String? = nil,
        value: String? = nil,
        valueTone: RowValueTone = .normal,
        secondary: String? = nil,
        tape: RowTape? = nil,
        options: RowOptions = []
    ) {
        self.init(name, icon: EmptyView(), subtitle: subtitle, value: value, valueTone: valueTone,
                  secondary: secondary, tape: tape, options: options, accessory: { EmptyView() })
    }
}

extension Row where Accessory == EmptyView {
    /// Creates a row with an icon (a `LetterTile`, symbol or thumbnail, drawn 22 pt square).
    public init(
        _ name: String,
        icon: Icon,
        subtitle: String? = nil,
        value: String? = nil,
        valueTone: RowValueTone = .normal,
        secondary: String? = nil,
        tape: RowTape? = nil,
        options: RowOptions = []
    ) {
        self.init(name, icon: icon, subtitle: subtitle, value: value, valueTone: valueTone,
                  secondary: secondary, tape: tape, options: options, accessory: { EmptyView() })
    }
}

extension Row where Icon == EmptyView {
    /// Creates a row with a trailing accessory and no icon.
    public init(
        _ name: String,
        subtitle: String? = nil,
        value: String? = nil,
        valueTone: RowValueTone = .normal,
        secondary: String? = nil,
        tape: RowTape? = nil,
        options: RowOptions = [],
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.init(name, icon: EmptyView(), subtitle: subtitle, value: value, valueTone: valueTone,
                  secondary: secondary, tape: tape, options: options, accessory: accessory)
    }
}

/// A 22 pt metal key-cap tile with an SF Symbol, for rows whose item has no app icon.
public struct SymbolTile: View {
    /// The SF Symbol name.
    public var systemName: String
    /// Draw only the symbol, without the metal tile.
    public var isBare: Bool

    @Environment(\.panelTheme) private var theme

    /// Creates a tile; pass `bare: true` for the symbol alone.
    public init(_ systemName: String, bare: Bool = false) {
        self.systemName = systemName
        self.isBare = bare
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: isBare ? 13 : 11, weight: isBare ? .regular : .semibold))
            .foregroundStyle(theme.ink)
            .frame(width: 22, height: 22)
            .background {
                if !isBare {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
                        .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(theme.button2Edge, lineWidth: 1))
                }
            }
            .accessibilityHidden(true)
    }
}

/// A 22 pt metal key-cap tile with a letter or symbol, for row icons.
public struct LetterTile: View {
    /// The character shown.
    public var text: String

    @Environment(\.panelTheme) private var theme

    /// Creates a tile.
    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(PanelFont.body(11, .semibold))
            .foregroundStyle(theme.ink)
            .frame(width: 22, height: 22)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
            )
            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(theme.button2Edge, lineWidth: 1))
            .accessibilityHidden(true)
    }
}
