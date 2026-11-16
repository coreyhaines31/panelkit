import SwiftUI

/// Data and labels for a forecast chart: a measured past line and a dashed projection towards a limit.
public struct ForecastConfig: Sendable {
    /// Past readings, oldest first, in data units.
    public var history: [Double]
    /// Bottom of the y axis in data units.
    public var lowerBound: Double
    /// The limit drawn as a dashed line, e.g. disk capacity.
    public var limit: Double
    /// Projected value at the right edge (defaults to the limit); set to nil afterwards to hide the projection.
    public var projection: Double?
    /// Where "today" sits across the width (0...1).
    public var todayPosition: Double
    /// Label at the bottom left, e.g. "Oct 16".
    public var startLabel: String
    /// Label under the today marker.
    public var todayLabel: String
    /// Label at the bottom right, e.g. "Full 26 Dec".
    public var endLabel: String?
    /// Label above the limit line, e.g. "994 GB".
    public var limitLabel: String?
    /// Draw the end point and end label in the stop colour.
    public var endIsAlarm: Bool
    /// Spoken summary of the chart.
    public var accessibilityLabel: String

    /// Creates a forecast configuration.
    public init(
        history: [Double],
        lowerBound: Double,
        limit: Double,
        projection: Double? = nil,
        todayPosition: Double = 150.0 / 312.0,
        startLabel: String,
        todayLabel: String = "Today",
        endLabel: String? = nil,
        limitLabel: String? = nil,
        endIsAlarm: Bool = true,
        accessibilityLabel: String
    ) {
        self.history = history
        self.lowerBound = lowerBound
        self.limit = limit
        self.projection = projection ?? limit
        self.todayPosition = todayPosition
        self.startLabel = startLabel
        self.todayLabel = todayLabel
        self.endLabel = endLabel
        self.limitLabel = limitLabel
        self.endIsAlarm = endIsAlarm
        self.accessibilityLabel = accessibilityLabel
    }
}

/// A forecast chart: past line with a light fill, today marker, dashed projection in the app accent, and a limit line.
public struct ForecastChart: View {
    /// The data and labels.
    public var config: ForecastConfig

    @Environment(\.panelTheme) private var theme
    @Environment(\.panelAccent) private var accent

    /// Creates a forecast chart.
    public init(_ config: ForecastConfig) {
        self.config = config
    }

    public var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            draw(&context, size: size)
        }
        .frame(height: 62)
        .padding(.top, 2)
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
        .accessibilityElement()
        .accessibilityLabel(config.accessibilityLabel)
        .accessibilityAddTraits(.isImage)
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize) {
        let width = size.width
        let height = size.height
        let top: CGFloat = 10
        let bottom = height - 14
        let nowX = width * config.todayPosition
        let endX = width - 14
        let span = max(config.limit - config.lowerBound, .ulpOfOne)
        func y(_ value: Double) -> CGFloat {
            bottom - CGFloat((value - config.lowerBound) / span) * (bottom - top)
        }
        let small = PanelFont.body(9)

        // Limit line and label.
        var limitPath = Path()
        limitPath.move(to: CGPoint(x: 0, y: y(config.limit)))
        limitPath.addLine(to: CGPoint(x: width, y: y(config.limit)))
        context.stroke(limitPath, with: .color(theme.sub), style: StrokeStyle(lineWidth: 0.8, dash: [3, 3]))
        if let limitLabel = config.limitLabel {
            drawText(&context, Text(limitLabel).font(small).foregroundStyle(theme.sub), x: 0, baseline: y(config.limit) - 3, anchor: .leading)
        }

        // Past line with fill.
        let history = config.history
        if history.count > 1 {
            var line = Path()
            for (index, value) in history.enumerated() {
                let point = CGPoint(x: nowX * CGFloat(index) / CGFloat(history.count - 1), y: y(value))
                if index == 0 { line.move(to: point) } else { line.addLine(to: point) }
            }
            var fill = line
            fill.addLine(to: CGPoint(x: nowX, y: bottom))
            fill.addLine(to: CGPoint(x: 0, y: bottom))
            fill.closeSubpath()
            context.fill(fill, with: .color(theme.fill.opacity(0.08)))
            context.stroke(line, with: .color(theme.fill), style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
        }

        let last = history.last ?? config.lowerBound
        let endColor = config.endIsAlarm ? theme.stop : theme.fill
        if let projection = config.projection {
            var dashed = Path()
            dashed.move(to: CGPoint(x: nowX, y: y(last)))
            dashed.addLine(to: CGPoint(x: endX, y: y(projection)))
            context.stroke(dashed, with: .color(accent), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            context.fill(Path(ellipseIn: CGRect(x: endX - 3, y: y(projection) - 3, width: 6, height: 6)), with: .color(endColor))
        }
        context.fill(Path(ellipseIn: CGRect(x: nowX - 2.6, y: y(last) - 2.6, width: 5.2, height: 5.2)), with: .color(theme.fill))

        // Baseline and axis labels.
        var axis = Path()
        axis.move(to: CGPoint(x: 0, y: bottom))
        axis.addLine(to: CGPoint(x: width, y: bottom))
        context.stroke(axis, with: .color(theme.sub.opacity(0.5)), lineWidth: 0.6)
        drawText(&context, Text(config.startLabel).font(small).foregroundStyle(theme.sub), x: 0, baseline: height - 2, anchor: .leading)
        drawText(&context, Text(config.todayLabel).font(small).foregroundStyle(theme.sub), x: nowX, baseline: height - 2, anchor: .center)
        if let endLabel = config.endLabel {
            let text = Text(endLabel).font(PanelFont.body(9, .semibold)).foregroundStyle(endColor)
            drawText(&context, text, x: width, baseline: height - 2, anchor: .trailing)
        }
    }

    private func drawText(_ context: inout GraphicsContext, _ text: Text, x: CGFloat, baseline: CGFloat, anchor: HorizontalAlignment) {
        let resolved = context.resolve(text)
        let bounds = CGSize(width: 400, height: 100)
        let size = resolved.measure(in: bounds)
        let base = resolved.firstBaseline(in: bounds)
        let originX: CGFloat
        switch anchor {
        case .leading: originX = x
        case .trailing: originX = x - size.width
        default: originX = x - size.width / 2
        }
        context.draw(resolved, in: CGRect(x: originX, y: baseline - base, width: size.width, height: size.height))
    }
}

/// A small graphite line chart of recent readings with a light fill.
public struct Sparkline: View {
    /// Readings, oldest first.
    public var values: [Double]
    /// Spoken summary.
    public var accessibilityLabel: String

    @Environment(\.panelTheme) private var theme

    /// Creates a sparkline.
    public init(_ values: [Double], accessibilityLabel: String) {
        self.values = values
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            guard values.count > 1, let low = values.min(), let high = values.max() else { return }
            let span = max(high - low, .ulpOfOne)
            var line = Path()
            for (index, value) in values.enumerated() {
                let point = CGPoint(
                    x: size.width * CGFloat(index) / CGFloat(values.count - 1),
                    y: 1 + (size.height - 2) * (1 - CGFloat((value - low) / span))
                )
                if index == 0 { line.move(to: point) } else { line.addLine(to: point) }
            }
            var fill = line
            fill.addLine(to: CGPoint(x: size.width, y: size.height))
            fill.addLine(to: CGPoint(x: 0, y: size.height))
            fill.closeSubpath()
            context.fill(fill, with: .color(theme.fill.opacity(0.08)))
            context.stroke(line, with: .color(theme.fill), style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
        }
        .frame(height: 24)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isImage)
    }
}
