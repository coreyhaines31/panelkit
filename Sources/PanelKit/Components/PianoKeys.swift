import SwiftUI

/// One option in a segmented control: the value it selects and its label.
public struct PanelChoice<Value: Hashable>: Hashable {
    /// The value selected by this option.
    public var value: Value
    /// The text on the key or tab.
    public var label: String

    /// Creates an option.
    public init(_ value: Value, _ label: String) {
        self.value = value
        self.label = label
    }
}

/// A segmented choice drawn as a row of black tape-deck keys; the pressed key sits lower and shows a lamp.
public struct PianoKeys<Value: Hashable>: View {
    /// The keys, in order.
    public var options: [PanelChoice<Value>]
    @Binding private var selection: Value

    @Environment(\.panelTheme) private var theme

    /// Creates piano keys bound to a selection.
    public init(_ options: [PanelChoice<Value>], selection: Binding<Value>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                Button {
                    selection = option.value
                } label: {
                    PianoKey(label: option.label, isPressed: option.value == selection, lamp: theme.caution)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.label)
                .accessibilityAddTraits(option.value == selection ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 2)
        .padding(.bottom, 10)
    }
}

struct PianoKey: View {
    let label: String
    let isPressed: Bool
    let lamp: Color

    var body: some View {
        Text(label)
            .panelCaps(10, tracking: 0.12)
            .foregroundStyle(isPressed ? Color.white : Color(hex: 0xC9CACB))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(LinearGradient(colors: [Color(hex: 0x2C2C2D), Color(hex: 0x161617)], startPoint: .top, endPoint: .bottom))
            )
            .overlay(alignment: .top) {
                // inset 0 1px 0 rgba(255,255,255,.08)
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(
                        LinearGradient(stops: [.init(color: .white.opacity(0.08), location: 0), .init(color: .clear, location: 0.06)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
            }
            .overlay(alignment: .top) {
                if isPressed {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(lamp)
                        .frame(width: 14, height: 3)
                        .lampGlow(lamp, radius: 5)
                        .padding(.top, 5)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black)
                    .offset(y: isPressed ? 0 : 2)
            )
            .offset(y: isPressed ? 2 : 0)
            .padding(.bottom, 2)
    }
}
