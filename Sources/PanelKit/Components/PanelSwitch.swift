import SwiftUI

/// A toggle style drawn as a small black-track switch with a spun-metal knob.
public struct PanelSwitchStyle: ToggleStyle {
    /// Creates the switch style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        SwitchBody(configuration: configuration)
    }

    private struct SwitchBody: View {
        let configuration: Configuration
        @Environment(\.panelTheme) private var theme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            HStack(spacing: 8) {
                configuration.label
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(configuration.isOn ? theme.switchOn : theme.track)
                        .overlay(
                            Capsule().strokeBorder(
                                LinearGradient(colors: [.black.opacity(0.25), .clear], startPoint: .top, endPoint: .center),
                                lineWidth: 1
                            )
                        )
                    Circle()
                        .fill(RadialGradient(colors: [.white, Color(hex: 0xB9BBBD)], center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: 8))
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                        .padding(2)
                }
                .frame(width: 30, height: 18)
                .contentShape(Capsule())
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                        configuration.isOn.toggle()
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(configuration.isOn ? "On" : "Off")
            .accessibilityAction { configuration.isOn.toggle() }
        }
    }
}

/// A standalone Brushed switch with no label.
public struct PanelSwitch: View {
    @Binding private var isOn: Bool
    private let accessibilityLabel: String

    /// Creates a switch; the label is spoken by VoiceOver only.
    public init(isOn: Binding<Bool>, accessibilityLabel: String) {
        self._isOn = isOn
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Toggle(isOn: $isOn) { EmptyView() }
            .toggleStyle(PanelSwitchStyle())
            .accessibilityLabel(accessibilityLabel)
    }
}

extension ToggleStyle where Self == PanelSwitchStyle {
    /// The Brushed switch.
    public static var panelSwitch: PanelSwitchStyle { PanelSwitchStyle() }
}
