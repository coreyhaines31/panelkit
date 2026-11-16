import PanelKit
import SwiftUI

/// The components added in 0.2, on one sheet.
struct AdditionsSheet: View {
    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            VStack(alignment: .leading, spacing: 32) {
                group("Fascia · leading and trailing keys · unlit pilot") {
                    Fascia(nameplate: "Awake", timestamp: "Idle", detail: "Pilot off when idle", label: "Unlit", isLit: false)
                    Fascia(nameplate: "Clips", detail: "142 kept", label: "Clipboard") {
                        TipStrip("Raise the camera to eye level so you look across, not up.", accessibilityPrefix: "Framing tip")
                    }
                    .leadingAccessory { KeyCap("chevron.left", accessibilityLabel: "Back") {} }
                    .trailingAccessory {
                        KeyCap("pause.fill", accessibilityLabel: "Pause") {}
                        KeyCap("gearshape.fill", accessibilityLabel: "Settings") {}
                    }
                }
                group("Buttons · KeyCap · links") {
                    HStack(spacing: 8) {
                        Button("Primary") {}.buttonStyle(.panelPrimary)
                        Button("Secondary") {}.buttonStyle(.panelSecondary)
                        Button("Quit Chrome") {}.buttonStyle(.panelDestructive)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    HStack(spacing: 8) {
                        Button("Refresh") {}.buttonStyle(.panelCompact)
                        Button("Stop") {}.buttonStyle(PanelButtonStyle(.destructive, size: .compact))
                        Button("Ignore") {}.buttonStyle(.panelQuietLink).font(PanelFont.body(12))
                        Spacer()
                        KeyCap("chevron.left", accessibilityLabel: "Back") {}
                        KeyCap("magnifyingglass", accessibilityLabel: "Search") {}
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    LinkBar {
                        Button("Usage page") {}
                        Button("Status") {}
                        Button("Docs ↗") {}
                    }
                    .padding(.bottom, 6)
                }
                group("Notice · NumberedSteps") {
                    SectionHeader("What to do")
                    NumberedSteps([
                        NumberedStep("Move closer to the router"),
                        NumberedStep("Run a speed test") {},
                        NumberedStep("Why Wi-Fi slows down", opensPage: true) {}
                    ])
                    Notice("Your plan caps speed at 100 Mbps", message: "No router setting fixes a plan limit.") {
                        Button("See what fixes this ›") {}
                    }
                    Notice("Headset is in call mode", message: "Input switched to the headset mic.") {
                        Button("Use the built-in mic") {}.buttonStyle(.panelCompact)
                        Button("Ignore") {}.buttonStyle(.panelQuietLink)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 32) {
                group("Row · wrapping subtitle · trailing slot · SymbolTile") {
                    SectionHeader("Free space", actionTitle: "Open Forecast…") {}
                    Row("5-hour window", subtitle: "Runs out around 3:40 PM, 1 h 20 m before the window resets at 5:00 PM",
                        secondary: "18%", tape: RowTape(0.18, projection: 0.62, status: .caution)) {
                        StatusLight(.caution, "Tight")
                    }
                    .subtitleLineLimit(2)
                    Row("Weekly", subtitle: "Headed for 74% by Thursday", value: "41%", tape: RowTape(0.41, projection: 0.74))
                    Row("Downloads", icon: SymbolTile("arrow.down.circle"), subtitle: "SymbolTile", value: "12 GB")
                    Row("Microphone", icon: SymbolTile("mic", bare: true), subtitle: "Bare symbol")
                        .trailingAccessory { Button("Test") {}.buttonStyle(.panelCompact) }
                    SectionHeader("Input")
                        .trailingAccessory { Button("Hear yourself") {}.buttonStyle(.panelCompact) }
                    HStack(spacing: 10) {
                        LevelMeter(level: 1, segments: 10, cautionFrom: 6, stopFrom: 9)
                        StatusLED(.go)
                        Text("Inline LED").font(PanelFont.body(11.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
                group("Disclosure · tint · trailing slot") {
                    Disclosure("Codex forecast", subtitle: "Runs out 1 h 20 m early", value: "18%") { EmptyView() }
                        .subtitleTint(.caution)
                    Disclosure("Camera", subtitle: "FaceTime HD") { EmptyView() }
                        .trailingAccessory { StatusLight(.go, "Live") }
                    Disclosure("Strays", subtitle: "2 processes") { EmptyView() }
                        .trailingAccessory { Button("Review") {}.buttonStyle(.panelCompact) }
                        .padding(.bottom, 4)
                }
                group("ForecastChart · dated · point labels") {
                    Spacer().frame(height: 8)
                    ForecastChart(GalleryData.datedForecast)
                    ForecastChart(GalleryData.collidingForecast)
                }
            }
            VStack(alignment: .leading, spacing: 32) {
                group("Recess · ReadingTile · ConfirmBox") {
                    HStack(spacing: 8) {
                        ReadingTile("Memory", value: "12.4 GB") { Tape(0.62) }
                        ReadingTile("Swap", value: "3.1 GB", status: .caution) { Text("Pressure rising") }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    Recess(tint: .stop) {
                        Text("Recess, stop tint").font(PanelFont.body(12))
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    ConfirmBox(
                        title: "Quit Google Chrome?",
                        message: "38 tabs close. Chrome reopens them next launch.",
                        warning: "2 tabs have unsaved forms",
                        actionTitle: "Quit Chrome",
                        cancel: {}, confirm: {}
                    )
                    .padding(14)
                }
                group("NativeSearchField · Field") {
                    Spacer().frame(height: 12)
                    NativeSearchField(text: .constant(""), prompt: "Search clipboard history", shortcut: "⌘F")
                    Field(text: .constant("invoice"), prompt: "Search", shortcut: "⌘F")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("MenuCard · automatic and always dark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    MenuSamples.coatCheck
                    MenuSamples.midnightOil
                }
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            Panel(accent: PanelAccent.diskForecast, content: content)
                .popoverShadow()
        }
    }
}

/// Native menus with a MenuCard on top, as Coat Check and Midnight Oil show them.
@MainActor
enum MenuSamples {
    static var coatCheck: some View {
        NativeMenu(items: ["Dropbox", "1Password", "Bartender"]) {
            MenuCard(accent: PanelAccent.coatCheck) {
                Fascia(nameplate: "Icons", timestamp: "14 in the menu bar")
                VerdictView("3 icons hidden by the notch", message: "Click one to open it in place.", status: .caution, statusLabel: "3 hidden")
            }
        }
    }

    static var midnightOil: some View {
        NativeMenu(items: ["Keep awake for 1 hour", "Until 6 PM", "Settings…"]) {
            MenuCard(accent: PanelAccent.midnightOil, appearance: .dark) {
                Fascia(nameplate: "Awake", timestamp: "Since 7:12 AM", label: "Keeping awake") {
                    Meter(
                        MeterConfig(
                            majorTicks: 4, minorTicks: 6,
                            bands: [MeterBand(0...0.25, width: 9, opacity: 0.14), MeterBand(0.75...1, width: 9, opacity: 0.14)],
                            labels: [.init(0, "0"), .init(0.25, "6"), .init(0.5, "12"), .init(0.75, "18"), .init(1, "24")],
                            word: "HOURS", face: .lit, accessibilityLabel: "24-hour meter"
                        ),
                        value: 0.403
                    )
                }
            }
        }
    }
}

/// A stand-in for the system menu around a card: translucent body, 10 pt corners, plain items.
struct NativeMenu<Card: View>: View {
    let card: Card
    let items: [String]
    @Environment(\.colorScheme) private var colorScheme

    init(items: [String], @ViewBuilder card: () -> Card) {
        self.card = card()
        self.items = items
    }

    var body: some View {
        let dark = colorScheme == .dark
        VStack(alignment: .leading, spacing: 0) {
            card
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 13))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 3)
            }
            Spacer().frame(height: 5)
        }
        .padding(.top, 5)
        .frame(width: MenuCard<EmptyView>.menuWidth, alignment: .leading)
        .foregroundStyle(dark ? Color(hex: 0xE6E7E8) : Color(hex: 0x161616))
        .background(dark ? Color(hex: 0x262628) : Color(hex: 0xECECEB))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.black.opacity(0.35), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.32), radius: 20, y: 18)
    }
}
