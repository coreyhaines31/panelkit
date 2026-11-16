import SwiftUI

/// Procedural brushed metal: fine horizontal grain over a vertical gradient with a diagonal sheen.
/// Brushed aluminium in light appearance, black anodised in dark.
public struct BrushedMetal: View {
    /// Draws black anodised metal instead of aluminium.
    public var anodised: Bool

    /// Creates brushed metal; pass `anodised: true` for the dark finish.
    public init(anodised: Bool = false) {
        self.anodised = anodised
    }

    public var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let base = anodised
                ? [Color(hex: 0x2B2B2C), Color(hex: 0x18181A)]
                : [Color(hex: 0xE7E8E9), Color(hex: 0xC3C5C7)]
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: base),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )

            // CSS linear-gradient(100deg, ...) sheen.
            let sheen = sheenLine(in: size, degrees: 100)
            let stops: [Gradient.Stop] = anodised
                ? [
                    .init(color: .white.opacity(0), location: 0.20),
                    .init(color: .white.opacity(0.07), location: 0.42),
                    .init(color: .white.opacity(0), location: 0.64)
                ]
                : [
                    .init(color: .white.opacity(0), location: 0.18),
                    .init(color: .white.opacity(0.5), location: 0.40),
                    .init(color: .white.opacity(0), location: 0.64)
                ]
            context.fill(
                Path(rect),
                with: .linearGradient(Gradient(stops: stops), startPoint: sheen.start, endPoint: sheen.end)
            )

            // Grain: repeating 1pt lines, bottom layer first (CSS lists the top layer first).
            let layers: [(period: CGFloat, offset: CGFloat, color: Color)] = anodised
                ? [
                    (9, 0, .white.opacity(0.03)),
                    (3, 0, .white.opacity(0.035))
                ]
                : [
                    (11, 0, .white.opacity(0.12)),
                    (7, 0, .black.opacity(0.035)),
                    (3, 0, .white.opacity(0.22)),
                    (3, 1, .black.opacity(0.035))
                ]
            for layer in layers {
                var path = Path()
                var y = layer.offset
                while y < size.height {
                    path.addRect(CGRect(x: 0, y: y, width: size.width, height: 1))
                    y += layer.period
                }
                context.fill(path, with: .color(layer.color))
            }
        }
        .accessibilityHidden(true)
    }

    private func sheenLine(in size: CGSize, degrees: Double) -> (start: CGPoint, end: CGPoint) {
        // Computed in Double and converted once: older Swift (Xcode 16) finds `sin` ambiguous between
        // the CGFloat and Double overloads when the two types mix in one expression.
        let rad = degrees * Double.pi / 180
        let dx = CGFloat(Foundation.sin(rad))
        let dy = CGFloat(-Foundation.cos(rad))
        let length = abs(size.width * dx) + abs(size.height * dy)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        return (
            CGPoint(x: center.x - dx * length / 2, y: center.y - dy * length / 2),
            CGPoint(x: center.x + dx * length / 2, y: center.y + dy * length / 2)
        )
    }
}

/// Chrome gradients shared by bezels and drums.
enum Chrome {
    /// The diagonal polished-chrome gradient used for meter bezels.
    static let bezel = Gradient(stops: [
        .init(color: Color(hex: 0xFBFBFB), location: 0),
        .init(color: Color(hex: 0x8C8E90), location: 0.35),
        .init(color: Color(hex: 0xEEEFF0), location: 0.55),
        .init(color: Color(hex: 0x6E7072), location: 0.8),
        .init(color: Color(hex: 0xD9DADB), location: 1)
    ])
}

extension View {
    /// A soft glow behind a lamp, like CSS `box-shadow: 0 0 Npx color`.
    func lampGlow(_ color: Color, radius: CGFloat) -> some View {
        shadow(color: color, radius: radius / 2)
    }
}
