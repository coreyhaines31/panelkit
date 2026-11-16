import SwiftUI

/// Small text tabs; the selected tab is a reversed black pill.
public struct Tabs<Value: Hashable>: View {
    /// The tabs, in order.
    public var options: [PanelChoice<Value>]
    @Binding private var selection: Value

    @Environment(\.panelTheme) private var theme

    /// Creates tabs bound to a selection.
    public init(_ options: [PanelChoice<Value>], selection: Binding<Value>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isOn = option.value == selection
                Button {
                    selection = option.value
                } label: {
                    Text(option.label)
                        .font(PanelFont.body(11.5, isOn ? .semibold : .regular))
                        .foregroundStyle(isOn ? theme.buttonInk : theme.sub)
                        .lineLimit(1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 9)
                        .background(isOn ? theme.button : .clear, in: RoundedRectangle(cornerRadius: 4))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }
}
