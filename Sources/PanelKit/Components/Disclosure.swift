import SwiftUI

/// An expandable row: a header with a turning chevron that reveals any content below it.
/// Keeps detailed features (forecast charts, full lists) one click away without crowding the popover.
public struct Disclosure<Content: View>: View {
    /// Header name.
    public var title: String
    /// Header subtitle.
    public var subtitle: String?
    /// Header value on the right.
    public var value: String?
    private let externalExpanded: Binding<Bool>?
    private let content: Content
    private var subtitleStatus: PanelStatus?
    private var trailing: AnyView?

    @State private var internalExpanded: Bool
    @Environment(\.panelTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a disclosure that manages its own expanded state.
    public init(
        _ title: String,
        subtitle: String? = nil,
        value: String? = nil,
        initiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.externalExpanded = nil
        self.content = content()
        _internalExpanded = State(initialValue: initiallyExpanded)
    }

    /// Creates a disclosure bound to external expanded state.
    public init(
        _ title: String,
        subtitle: String? = nil,
        value: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.externalExpanded = isExpanded
        self.content = content()
        _internalExpanded = State(initialValue: isExpanded.wrappedValue)
    }

    private var isExpanded: Bool {
        externalExpanded?.wrappedValue ?? internalExpanded
    }

    private func toggle() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            if let externalExpanded {
                externalExpanded.wrappedValue.toggle()
            } else {
                internalExpanded.toggle()
            }
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                header
                // Outside the header button, so buttons here get their own clicks.
                if let trailing {
                    HStack(spacing: 6) { trailing }
                        .fixedSize()
                        .frame(minHeight: 22)
                        .padding(.top, 7)
                        .padding(.trailing, 14)
                }
            }

            if isExpanded {
                content
                    .transition(.opacity)
            }
        }
    }

    private var header: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: 10) {
                DisclosureKnob(isExpanded: isExpanded)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(PanelFont.body(13, .semibold))
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                    if let subtitle {
                        Text(subtitle)
                            .font(PanelFont.body(11.5, subtitleStatus == nil ? .regular : .medium))
                            .foregroundStyle(subtitleStatus.map { theme.color(for: $0) } ?? theme.sub)
                            .lineLimit(1)
                    }
                }
                .padding(.top, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                if let value {
                    Text(value)
                        .font(PanelFont.body(13))
                        .monospacedDigit()
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.top, 3)
                }
            }
            .padding(.vertical, 7)
            .padding(.leading, 14)
            .padding(.trailing, trailing == nil ? 14 : 0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(isExpanded ? "Hide" : "Show") \(title)")
        .accessibilityValue(subtitle ?? "")
        .accessibilityAddTraits(.isButton)
    }

    /// Tints the header subtitle in a status colour, e.g. caution when a forecast runs short.
    public func subtitleTint(_ status: PanelStatus?) -> Disclosure {
        var copy = self
        copy.subtitleStatus = status
        return copy
    }

    /// Puts views (a `StatusLight`, compact buttons) at the right of the header, after the value.
    public func trailingAccessory<V: View>(@ViewBuilder _ accessory: () -> V) -> Disclosure {
        var copy = self
        copy.trailing = AnyView(accessory())
        return copy
    }
}

/// The 22 pt round metal button with a bold chevron that turns when the disclosure opens.
struct DisclosureKnob: View {
    let isExpanded: Bool

    @Environment(\.panelTheme) private var theme

    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(theme.ink)
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .frame(width: 22, height: 22)
            .background(
                Circle().fill(LinearGradient(colors: theme.button2, startPoint: .top, endPoint: .bottom))
            )
            .overlay(Circle().strokeBorder(theme.button2Edge, lineWidth: 1))
            .overlay(
                Circle()
                    .strokeBorder(.white.opacity(theme.isDark ? 0.08 : 0.6), lineWidth: 1)
                    .padding(1)
            )
            .shadow(color: .black.opacity(0.08), radius: 0, y: 1)
            .accessibilityHidden(true)
    }
}
