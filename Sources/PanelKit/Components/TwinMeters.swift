import SwiftUI

/// One channel of a `TwinMeters` pair: a meter, its value and its label strips.
public struct MeterChannel: Sendable {
    /// The meter's configuration (usually `MeterConfig.twin(...)`).
    public var config: MeterConfig
    /// Needle position (0...1).
    public var value: Double
    /// Spoken value, e.g. "148 milliseconds".
    public var accessibilityValue: String?
    /// Main strip text, e.g. "Wi-Fi".
    public var label: String
    /// Outlined strip text, e.g. "Your side".
    public var detail: String?

    /// Creates a channel.
    public init(_ config: MeterConfig, value: Double, accessibilityValue: String? = nil, label: String, detail: String? = nil) {
        self.config = config
        self.value = value
        self.accessibilityValue = accessibilityValue
        self.label = label
        self.detail = detail
    }
}

/// Two meters side by side with their own label strips, like a deck's two channels.
public struct TwinMeters: View {
    /// Left channel.
    public var left: MeterChannel
    /// Right channel.
    public var right: MeterChannel

    /// Creates a pair of meters.
    public init(left: MeterChannel, right: MeterChannel) {
        self.left = left
        self.right = right
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            channel(left)
            channel(right)
        }
    }

    private func channel(_ channel: MeterChannel) -> some View {
        VStack(spacing: 10) {
            Meter(channel.config, value: channel.value, accessibilityValue: channel.accessibilityValue)
            LabelStrips(channel.label, detail: channel.detail)
        }
        .frame(maxWidth: .infinity)
    }
}
