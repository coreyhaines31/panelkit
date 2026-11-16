import SwiftUI

/// A chrome ring around a live view, such as a camera preview, sized to fill the fascia's width.
public struct ChromeBezel<Content: View>: View {
    /// Width-to-height ratio of the window.
    public var aspectRatio: CGFloat
    private let content: Content

    /// Creates a bezel around content.
    public init(aspectRatio: CGFloat = 16.0 / 9.0, @ViewBuilder content: () -> Content) {
        self.aspectRatio = aspectRatio
        self.content = content()
    }

    public var body: some View {
        content
            .aspectRatio(aspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.08)),
                        lineWidth: 2
                    )
            )
            .padding(3)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color(hex: 0xB7B9BB)))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.black.opacity(0.35), lineWidth: 1).padding(-1))
            .padding(4)
    }
}

/// A tally lamp label for a live view, e.g. "LIVE" with a red light.
public struct TallyLight: View {
    /// The word on the tally.
    public var label: String

    @Environment(\.panelTheme) private var theme

    /// Creates a tally light.
    public init(_ label: String = "LIVE") {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(hex: 0xFF5A3C))
                .frame(width: 6, height: 6)
                .lampGlow(Color(hex: 0xFF5A3C), radius: 5)
            Text(label)
                .panelCaps(9.5, tracking: 0.2)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 2))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}
