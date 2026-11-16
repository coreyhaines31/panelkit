import SwiftUI

/// The metal fascia that opens every popover: nameplate and timestamp, an instrument, then label strips.
/// Add keys to the header with `leadingAccessory(_:)` (a back key) and `trailingAccessory(_:)` (toolbar keys).
public struct Fascia<Content: View>: View {
    /// Nameplate text, e.g. "FUEL"; an empty string draws no nameplate.
    public var nameplate: String
    /// Whether the nameplate's pilot light is lit (off for idle states).
    public var isLit: Bool
    /// Text at the top right, e.g. "Updated 9:41 AM".
    public var timestamp: String?
    /// Outlined detail strip text.
    public var detail: String?
    /// Main label strip text; no strips are drawn when nil.
    public var label: String?
    private let content: Content
    private var leading: AnyView?
    private var trailing: AnyView?

    @Environment(\.panelTheme) private var theme

    /// Creates a fascia around an instrument (a `Meter`, `TwinMeters`, `Counter` or any view).
    public init(
        nameplate: String,
        timestamp: String? = nil,
        detail: String? = nil,
        label: String? = nil,
        isLit: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.nameplate = nameplate
        self.isLit = isLit
        self.timestamp = timestamp
        self.detail = detail
        self.label = label
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                if let leading {
                    HStack(spacing: 4) { leading }
                }
                if !nameplate.isEmpty {
                    Nameplate(nameplate, isLit: isLit)
                }
                Spacer(minLength: 0)
                if let timestamp {
                    Text(timestamp)
                        .font(PanelFont.body(11.5))
                        .monospacedDigit()
                        .foregroundStyle(theme.ink2)
                        .lineLimit(1)
                }
                if let trailing {
                    HStack(spacing: 4) { trailing }
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

    /// Puts views (usually a `KeyCap` back key) before the nameplate. Pass `isPresented: false` to leave
    /// the slot out entirely, so the nameplate keeps its place (an empty builder still takes up room).
    public func leadingAccessory<V: View>(isPresented: Bool = true, @ViewBuilder _ accessory: () -> V) -> Fascia {
        var copy = self
        copy.leading = isPresented ? AnyView(accessory()) : nil
        return copy
    }

    /// Puts views (usually `KeyCap` toolbar keys) at the right of the header, after any timestamp.
    public func trailingAccessory<V: View>(@ViewBuilder _ accessory: () -> V) -> Fascia {
        var copy = self
        copy.trailing = AnyView(accessory())
        return copy
    }
}

extension Fascia where Content == EmptyView {
    /// Creates a fascia with only the nameplate row and strips.
    public init(nameplate: String, timestamp: String? = nil, detail: String? = nil, label: String? = nil, isLit: Bool = true) {
        self.init(nameplate: nameplate, timestamp: timestamp, detail: detail, label: label, isLit: isLit) { EmptyView() }
    }
}
