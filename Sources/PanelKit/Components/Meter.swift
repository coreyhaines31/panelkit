import SwiftUI

/// A label on a meter scale at a normalised position (0...1).
public struct MeterLabel: Sendable, Hashable {
    /// Position on the scale, 0 at the left stop, 1 at the right stop.
    public var value: Double
    /// The text printed at that position.
    public var text: String

    /// Creates a scale label.
    public init(_ value: Double, _ text: String) {
        self.value = value
        self.text = text
    }
}

/// A printed band on the meter face inside the scale (e.g. Midnight Oil's night hours).
public struct MeterBand: Sendable, Hashable {
    /// Start and end on the scale (0...1).
    public var range: ClosedRange<Double>
    /// Stroke width in meter units.
    public var width: CGFloat
    /// Stroke opacity.
    public var opacity: Double

    /// Creates a band; it is printed in the face's ink colour.
    public init(_ range: ClosedRange<Double>, width: CGFloat = 4, opacity: Double = 1) {
        self.range = range
        self.width = width
        self.opacity = opacity
    }
}

/// Which face a meter shows.
public enum MeterFace: Sendable {
    /// Cream in light appearance, lit amber in dark.
    case automatic
    /// Cream face with black ink.
    case cream
    /// Backlit amber face, for night use.
    case lit
}

/// Everything that describes a VU-style meter except the needle values.
public struct MeterConfig: Sendable {
    /// Design size in points; the meter scales to the width it is given and keeps this aspect.
    public var size: CGSize
    /// Half the sweep angle in degrees (the scale runs from -sweep to +sweep).
    public var sweep: Double
    /// Number of major divisions.
    public var majorTicks: Int
    /// Minor divisions per major division.
    public var minorTicks: Int
    /// Red zones on the scale (0...1).
    public var zones: [ClosedRange<Double>]
    /// Bands printed inside the scale.
    public var bands: [MeterBand]
    /// Labels outside the scale.
    public var labels: [MeterLabel]
    /// Small labels inside the scale.
    public var innerLabels: [MeterLabel]
    /// Font size of the outer labels.
    public var labelSize: CGFloat
    /// The large word printed on the face, e.g. "LIMIT".
    public var word: String?
    /// Font size of the word.
    public var wordSize: CGFloat
    /// Face finish.
    public var face: MeterFace
    /// Spoken name of the meter, e.g. "Fuel meter".
    public var accessibilityLabel: String

    /// Creates a meter configuration. Defaults match the 312 x 104 single meter.
    public init(
        size: CGSize = CGSize(width: 312, height: 104),
        sweep: Double = 44,
        majorTicks: Int = 10,
        minorTicks: Int = 2,
        zones: [ClosedRange<Double>] = [],
        bands: [MeterBand] = [],
        labels: [MeterLabel] = [],
        innerLabels: [MeterLabel] = [],
        labelSize: CGFloat = 10.5,
        word: String? = nil,
        wordSize: CGFloat = 22,
        face: MeterFace = .automatic,
        accessibilityLabel: String
    ) {
        self.size = size
        self.sweep = sweep
        self.majorTicks = max(1, majorTicks)
        self.minorTicks = max(1, minorTicks)
        self.zones = zones
        self.bands = bands
        self.labels = labels
        self.innerLabels = innerLabels
        self.labelSize = labelSize
        self.word = word
        self.wordSize = wordSize
        self.face = face
        self.accessibilityLabel = accessibilityLabel
    }

    /// The configuration for one of a pair of side-by-side meters (152 x 92).
    public static func twin(
        majorTicks: Int = 4,
        minorTicks: Int = 4,
        zones: [ClosedRange<Double>] = [],
        labels: [MeterLabel] = [],
        word: String? = nil,
        face: MeterFace = .automatic,
        accessibilityLabel: String
    ) -> MeterConfig {
        MeterConfig(
            size: CGSize(width: 152, height: 92),
            sweep: 42,
            majorTicks: majorTicks,
            minorTicks: minorTicks,
            zones: zones,
            labels: labels,
            labelSize: 9.5,
            word: word,
            wordSize: 16,
            face: face,
            accessibilityLabel: accessibilityLabel
        )
    }
}

/// Shared geometry for a meter in design units.
struct MeterGeometry {
    let width: CGFloat
    let height: CGFloat
    let sweep: Double

    var cx: CGFloat { width / 2 }
    var radius: CGFloat { min(118, width * 0.42) }
    var cy: CGFloat { 24 + radius }

    init(_ config: MeterConfig) {
        width = config.size.width
        height = config.size.height
        sweep = config.sweep
    }

    func angle(_ value: Double) -> Double { -sweep + value * 2 * sweep }

    /// Point at `radius` from the pivot at a dial angle in degrees (0 = straight up).
    func point(_ r: CGFloat, _ degrees: Double) -> CGPoint {
        let a = (degrees - 90) * .pi / 180
        return CGPoint(x: cx + r * CGFloat(cos(a)), y: cy + r * CGFloat(sin(a)))
    }

    func arc(_ r: CGFloat, from v0: Double, to v1: Double) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: r,
            startAngle: .degrees(angle(v0) - 90),
            endAngle: .degrees(angle(v1) - 90),
            clockwise: false
        )
        return path
    }

    var faceRect: CGRect { CGRect(x: 3, y: 3, width: width - 6, height: height - 6) }
}

struct MeterInk {
    let ink: Color
    let red: Color
    let faceStops: [Gradient.Stop]
    let lit: Bool

    init(lit: Bool) {
        self.lit = lit
        if lit {
            ink = Color(hex: 0x2A2216)
            red = Color(hex: 0xC4301A)
            faceStops = [.init(color: Color(hex: 0xE4B768), location: 0), .init(color: Color(hex: 0xF6DFAA), location: 0.75)]
        } else {
            ink = Color(hex: 0x1D1D1D)
            red = Color(hex: 0xD1381F)
            faceStops = [.init(color: Color(hex: 0xE2DDCF), location: 0), .init(color: Color(hex: 0xF4F2EB), location: 0.7)]
        }
    }
}

/// A rectangular VU-style meter in a chrome bezel: cream face, black ink, red zones, one or more needles.
public struct Meter: View {
    /// The meter's scale, face and labels.
    public var config: MeterConfig
    /// Needle positions on the scale (0...1), one per needle.
    public var values: [Double]
    /// Spoken value; defaults to the first needle as a percentage.
    public var accessibilityValue: String?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a single-needle meter.
    public init(_ config: MeterConfig, value: Double, accessibilityValue: String? = nil) {
        self.init(config, values: [value], accessibilityValue: accessibilityValue)
    }

    /// Creates a meter with several needles.
    public init(_ config: MeterConfig, values: [Double], accessibilityValue: String? = nil) {
        self.config = config
        self.values = values
        self.accessibilityValue = accessibilityValue
    }

    private var isLit: Bool {
        switch config.face {
        case .automatic: colorScheme == .dark
        case .cream: false
        case .lit: true
        }
    }

    public var body: some View {
        let geometry = MeterGeometry(config)
        let ink = MeterInk(lit: isLit)
        let face = FaceShape(geometry: geometry)
        ZStack {
            MeterBack(config: config, geometry: geometry, ink: ink)
            ZStack {
                ForEach(values.indices, id: \.self) { index in
                    NeedleShape(geometry: geometry, value: clamp(values[index]))
                        .stroke(ink.ink, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
                MeterFront(geometry: geometry, lit: isLit)
            }
            .clipShape(face)
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.62), value: values)
            ScrewDot(geometry: geometry)
        }
        .aspectRatio(config.size.width / config.size.height, contentMode: .fit)
        .shadow(color: isLit || colorScheme == .dark ? .clear : .white.opacity(0.5), radius: 0, x: 0, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(config.accessibilityLabel)
        .accessibilityValue(accessibilityValue ?? defaultAccessibilityValue)
    }

    private var defaultAccessibilityValue: String {
        values.map { "\(Int((clamp($0) * 100).rounded())) percent" }.joined(separator: ", ")
    }

    private func clamp(_ value: Double) -> Double { min(max(value, -0.02), 1.02) }
}

/// The face's rounded rect in view space.
struct FaceShape: Shape {
    let geometry: MeterGeometry

    func path(in rect: CGRect) -> Path {
        let s = rect.width / geometry.width
        return Path(roundedRect: geometry.faceRect, cornerRadius: 4)
            .applying(CGAffineTransform(scaleX: s, y: s))
    }
}

/// One needle, animatable along the scale.
struct NeedleShape: Shape {
    let geometry: MeterGeometry
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let s = rect.width / geometry.width
        let tip = geometry.point(geometry.radius + 9, geometry.angle(value))
        var path = Path()
        path.move(to: CGPoint(x: geometry.cx * s, y: geometry.cy * s))
        path.addLine(to: CGPoint(x: tip.x * s, y: tip.y * s))
        return path
    }
}

/// Bezel, face, scale, labels and word.
struct MeterBack: View {
    let config: MeterConfig
    let geometry: MeterGeometry
    let ink: MeterInk

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let g = geometry
            let s = size.width / g.width
            context.scaleBy(x: s, y: s)

            // Chrome bezel, gradient in bounding-box space like the SVG.
            let bezelRect = CGRect(x: 1.5, y: 1.5, width: g.width - 3, height: g.height - 3)
            var bezel = context
            bezel.clip(to: Path(roundedRect: bezelRect, cornerRadius: 5.5))
            bezel.translateBy(x: bezelRect.minX, y: bezelRect.minY)
            bezel.scaleBy(x: bezelRect.width, y: bezelRect.height)
            bezel.fill(
                Path(CGRect(x: 0, y: 0, width: 1, height: 1)),
                with: .linearGradient(Chrome.bezel, startPoint: .zero, endPoint: CGPoint(x: 1, y: 1))
            )

            // Face: elliptical radial gradient centred below the window.
            let faceRect = g.faceRect
            var face = context
            face.clip(to: Path(roundedRect: faceRect, cornerRadius: 4))
            let rx = faceRect.width
            let ry = faceRect.height
            face.translateBy(x: faceRect.midX, y: faceRect.minY + faceRect.height * 1.1)
            face.scaleBy(x: 1, y: ry / rx)
            face.fill(
                Path(CGRect(x: -rx * 2, y: -rx * 2, width: rx * 4, height: rx * 4)),
                with: .radialGradient(Gradient(stops: ink.faceStops), center: .zero, startRadius: 0, endRadius: rx)
            )

            var dial = context
            dial.clip(to: Path(roundedRect: faceRect, cornerRadius: 4))
            drawScale(&dial)
        }
    }

    private func isHot(_ value: Double) -> Bool {
        config.zones.contains { value >= $0.lowerBound - 1e-6 && value <= $0.upperBound + 1e-6 }
    }

    private func drawScale(_ context: inout GraphicsContext) {
        let g = geometry
        let r = g.radius

        for band in config.bands {
            context.stroke(
                g.arc(r - 6, from: band.range.lowerBound, to: band.range.upperBound),
                with: .color(ink.ink.opacity(band.opacity)),
                lineWidth: band.width
            )
        }
        context.stroke(g.arc(r, from: 0, to: 1), with: .color(ink.ink), lineWidth: 1)
        for zone in config.zones {
            context.stroke(g.arc(r + 2, from: zone.lowerBound, to: zone.upperBound), with: .color(ink.red), lineWidth: 3.2)
        }

        let count = config.majorTicks * config.minorTicks
        for i in 0...count {
            let v = Double(i) / Double(count)
            let major = i % config.minorTicks == 0
            let a = g.point(r, g.angle(v))
            let b = g.point(r + (major ? 7 : 4), g.angle(v))
            var tick = Path()
            tick.move(to: a)
            tick.addLine(to: b)
            context.stroke(tick, with: .color(isHot(v) ? ink.red : ink.ink), lineWidth: major ? 1.4 : 0.8)
        }

        for label in config.labels {
            let p = g.point(r + 15, g.angle(label.value))
            let text = Text(label.text)
                .font(PanelFont.condensed(config.labelSize, .semibold))
                .foregroundStyle(isHot(label.value) ? ink.red : ink.ink)
            drawText(&context, text, centerX: p.x, baseline: p.y + 3.4)
        }

        for label in config.innerLabels {
            let p = g.point(r - 12, g.angle(label.value))
            let text = Text(label.text)
                .font(PanelFont.condensed(7, .medium))
                .foregroundStyle(ink.ink.opacity(0.7))
            drawText(&context, text, centerX: p.x, baseline: p.y + 2.6)
        }

        if let word = config.word {
            let text = Text(word)
                .font(PanelFont.condensed(config.wordSize, .light))
                .tracking(3)
                .foregroundStyle(ink.ink.opacity(0.85))
            drawText(&context, text, centerX: g.cx + 1.5, baseline: g.height - 22)
        }
    }

    private func drawText(_ context: inout GraphicsContext, _ text: Text, centerX: CGFloat, baseline: CGFloat) {
        let resolved = context.resolve(text)
        let bounds = CGSize(width: 400, height: 100)
        let measured = resolved.measure(in: bounds)
        let base = resolved.firstBaseline(in: bounds)
        let rect = CGRect(x: centerX - measured.width / 2, y: baseline - base, width: measured.width, height: measured.height)
        context.draw(resolved, in: rect)
    }
}

/// The black pivot housing and the glass highlight, drawn over the needles.
struct MeterFront: View {
    let geometry: MeterGeometry
    let lit: Bool

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let g = geometry
            let s = size.width / g.width
            context.scaleBy(x: s, y: s)
            let rx = g.width * 0.16
            context.fill(
                Path(ellipseIn: CGRect(x: g.cx - rx, y: g.height + 2 - 14, width: rx * 2, height: 28)),
                with: .color(Color(hex: 0x1B1B1B).opacity(lit ? 0.55 : 0.8))
            )
            context.fill(
                Path(CGRect(x: 3, y: 3, width: g.width - 6, height: 14)),
                with: .color(.white.opacity(lit ? 0.05 : 0.18))
            )
        }
        .allowsHitTesting(false)
    }
}

/// The zero-adjust screw at the top left of the window.
struct ScrewDot: View {
    let geometry: MeterGeometry

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let s = size.width / geometry.width
            context.scaleBy(x: s, y: s)
            context.fill(Path(ellipseIn: CGRect(x: 8, y: 8, width: 6, height: 6)), with: .color(Color(hex: 0x1B1B1B).opacity(0.75)))
        }
        .allowsHitTesting(false)
    }
}
