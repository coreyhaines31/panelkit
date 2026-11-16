import SwiftUI

/// One step in `NumberedSteps`.
public struct NumberedStep {
    /// The step text.
    public var title: String
    /// Adds " ↗" for steps that open a web page.
    public var opensPage: Bool
    /// What VoiceOver says the step does, e.g. "Opens a guide on wifiorisp.com".
    public var hint: String?
    /// Makes the step a link; nil for plain text.
    public var perform: (() -> Void)?

    /// Creates a step; give it `perform` to make it a link.
    public init(_ title: String, opensPage: Bool = false, hint: String? = nil, perform: (() -> Void)? = nil) {
        self.title = title
        self.opensPage = opensPage
        self.hint = hint
        self.perform = perform
    }
}

/// A numbered list of next steps ("What to do"); steps with an action are drawn as links.
public struct NumberedSteps: View {
    /// The steps, in order.
    public var steps: [NumberedStep]

    @Environment(\.panelTheme) private var theme

    /// Creates the list.
    public init(_ steps: [NumberedStep]) {
        self.steps = steps
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                if let perform = step.perform {
                    Button(action: perform) { row(index, step, isLink: true) }
                        .buttonStyle(.plain)
                        .accessibilityHint(step.hint ?? "")
                } else {
                    row(index, step, isLink: false)
                }
            }
        }
        .font(PanelFont.body(12))
        .padding(EdgeInsets(top: 0, leading: 14, bottom: 8, trailing: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ index: Int, _ step: NumberedStep, isLink: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(index + 1).")
                .monospacedDigit()
                .foregroundStyle(theme.sub)
                .frame(minWidth: 12, alignment: .trailing)
            Text(step.title + (step.opensPage ? " ↗" : ""))
                .foregroundStyle(isLink ? theme.link : theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .contentShape(Rectangle())
    }
}
