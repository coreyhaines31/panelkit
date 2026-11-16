import SwiftUI

/// A recessed box in the field colour with a hairline edge, optionally tinted by a status.
/// It has no outer padding; place it inside padded content or a grid.
public struct Recess<Content: View>: View {
    /// Tints the fill and edge in a status colour; nil keeps the field colour.
    public var tint: PanelStatus?
    /// Inner padding.
    public var padding: EdgeInsets
    private let content: Content

    @Environment(\.panelTheme) private var theme

    /// Creates a recess.
    public init(
        tint: PanelStatus? = nil,
        padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        let color = tint.map { theme.color(for: $0) }
        let shape = RoundedRectangle(cornerRadius: 6)
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(shape.fill(color.map { $0.opacity(0.12) } ?? theme.field))
            .overlay(shape.strokeBorder(color.map { $0.opacity(0.4) } ?? theme.line, lineWidth: 1))
    }
}
