import AppKit
import SwiftUI

/// `Field` around an AppKit `NSSearchField`, for lists driven from the search box: ↑ and ↓ move the
/// selection, Return submits and Esc cancels while the text keeps focus, which a SwiftUI `TextField` can't do.
public struct NativeSearchField: View {
    @Binding private var text: String
    /// Placeholder text, e.g. "Search clipboard history".
    public var prompt: String
    /// Shortcut hint, e.g. "⌘F".
    public var shortcut: String?
    /// Change this value to focus the field and select its text (e.g. on ⌘F or when the panel opens).
    public var focusRequest: Int
    /// Focus the field as soon as it is in a window.
    public var focusesOnAppear: Bool
    private let onSubmit: (() -> Void)?
    private let onMove: ((MoveCommandDirection) -> Void)?
    private let onCancel: (() -> Void)?

    @Environment(\.panelTheme) private var theme
    @Environment(\.panelSnapshot) private var snapshot

    /// Creates a search field. Handlers you leave nil keep AppKit's default for that key.
    public init(
        text: Binding<String>,
        prompt: String,
        shortcut: String? = nil,
        focusRequest: Int = 0,
        focusesOnAppear: Bool = true,
        onSubmit: (() -> Void)? = nil,
        onMove: ((MoveCommandDirection) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.prompt = prompt
        self.shortcut = shortcut
        self.focusRequest = focusRequest
        self.focusesOnAppear = focusesOnAppear
        self.onSubmit = onSubmit
        self.onMove = onMove
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11.5, weight: .medium))
                .frame(width: 13, height: 13)
                .accessibilityHidden(true)
            Group {
                if snapshot {
                    Text(text.isEmpty ? prompt : text)
                        .font(PanelFont.body(12.5))
                        .foregroundStyle(text.isEmpty ? theme.sub : theme.ink)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    SearchFieldBridge(
                        text: $text,
                        prompt: prompt,
                        focusRequest: focusRequest,
                        focusesOnAppear: focusesOnAppear,
                        textColor: NSColor(theme.ink),
                        onSubmit: onSubmit,
                        onMove: onMove,
                        onCancel: onCancel
                    )
                }
            }
            .frame(height: 18)
            if let shortcut {
                Text(shortcut)
                    .font(PanelFont.body(11))
                    .accessibilityHidden(true)
            }
        }
        .modifier(FieldChrome(verticalPadding: 5))
    }
}

private struct SearchFieldBridge: NSViewRepresentable {
    @Binding var text: String
    let prompt: String
    let focusRequest: Int
    let focusesOnAppear: Bool
    let textColor: NSColor
    let onSubmit: (() -> Void)?
    let onMove: ((MoveCommandDirection) -> Void)?
    let onCancel: (() -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeNSView(context: Context) -> NSSearchField {
        let field = BrushedSearchField()
        field.focusesOnAppear = focusesOnAppear
        field.placeholderString = prompt
        field.setAccessibilityLabel(prompt)
        field.sendsSearchStringImmediately = true
        field.isBezeled = false
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = .systemFont(ofSize: 12.5)
        field.textColor = textColor
        // The well draws its own magnifier; the unbezeled cell would draw another over the text.
        (field.cell as? NSSearchFieldCell)?.searchButtonCell = nil
        field.delegate = context.coordinator
        context.coordinator.focusRequest = focusRequest
        return field
    }

    func updateNSView(_ field: NSSearchField, context: Context) {
        context.coordinator.parent = self
        if field.stringValue != text { field.stringValue = text }
        field.placeholderString = prompt
        field.textColor = textColor
        if context.coordinator.focusRequest != focusRequest {
            context.coordinator.focusRequest = focusRequest
            Task { @MainActor in
                field.window?.makeFirstResponder(field)
                field.selectText(nil)
            }
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchFieldBridge
        var focusRequest = 0

        init(parent: SearchFieldBridge) {
            self.parent = parent
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSSearchField else { return }
            parent.text = field.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy command: Selector) -> Bool {
            switch command {
            case #selector(NSResponder.moveUp(_:)):
                guard let onMove = parent.onMove else { return false }
                onMove(.up)
            case #selector(NSResponder.moveDown(_:)):
                guard let onMove = parent.onMove else { return false }
                onMove(.down)
            case #selector(NSResponder.insertNewline(_:)):
                guard let onSubmit = parent.onSubmit else { return false }
                onSubmit()
            case #selector(NSResponder.cancelOperation(_:)):
                guard let onCancel = parent.onCancel else { return false }
                onCancel()
            default:
                return false
            }
            return true
        }
    }
}

private final class BrushedSearchField: NSSearchField {
    var focusesOnAppear = true

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if focusesOnAppear, let window { window.makeFirstResponder(self) }
    }
}
