import SwiftUI

/// The metal fascia that opens every popover: nameplate and timestamp, an instrument, then label strips.
public struct Fascia<Content: View>: View {
    /// Nameplate text, e.g. "FUEL".
    public var nameplate: String
    /// Text at the top right, e.g. "Updated 9:41 AM".
    public var timestamp: String?
    /// Outlined detail strip text.
    public var detail: String?
    /// Main label strip text; no strips are drawn when nil.
    public var label: String?
    private let content: Content

    @Environment(\.panelTheme) private var theme

    /// Creates a fascia around an instrument (a `Meter`, `TwinMeters`, `Counter` or any view).
    public init(
        nameplate: String,
        timestamp: String? = nil,
        detail: String? = nil,
        label: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.nameplate = nameplate
        self.timestamp = timestamp
        self.detail = detail
        self.label = label
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Nameplate(nameplate)
                Spacer(minLength: 0)
                if let timestamp {
                    Text(timestamp)
                        .font(PanelFont.body(11.5))
                        .monospacedDigit()
                        .foregroundStyle(theme.ink2)
                        .lineLimit(1)
                }
            }
            content
            if let label {
                LabelStrips(label, detail: detail)
            }
        }
        .padding(.top, 11)
        .padding(.horizontal, 14)
        .padding(.bottom, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrushedMetal(anodised: theme.isDark))
        .overlay(alignment: .top) {
            Rectangle().fill(theme.fasciaHighlight).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.fasciaEdge).frame(height: 1)
        }
    }
}

extension Fascia where Content == EmptyView {
    /// Creates a fascia with only the nameplate row and strips.
    public init(nameplate: String, timestamp: String? = nil, detail: String? = nil, label: String? = nil) {
        self.init(nameplate: nameplate, timestamp: timestamp, detail: detail, label: label) { EmptyView() }
    }
}
