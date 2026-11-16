import PanelKit
import SwiftUI

/// Every PanelKit component on one sheet, grouped into labelled panels.
struct ComponentSheet: View {
    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            VStack(alignment: .leading, spacing: 32) {
                group("Fascia · Nameplate · Meter · LabelStrips") {
                    Fascia(nameplate: "Fuel", timestamp: "Updated 9:41 AM", detail: "Outlined detail strip", label: "Main strip") {
                        Meter(
                            MeterConfig(
                                majorTicks: 10, minorTicks: 2, zones: [0.8...1],
                                labels: [.init(0, "0"), .init(0.2, "2"), .init(0.4, "4"), .init(0.6, "6"), .init(0.8, "8"), .init(1, "10")],
                                innerLabels: [.init(0, "min"), .init(1, "max")],
                                word: "LOAD", accessibilityLabel: "Sample meter"
                            ),
                            values: [0.3, 0.86]
                        )
                    }
                }
                group("Meter · lit face · bands") {
                    Fascia(nameplate: "Awake", timestamp: "Since 7:12 AM") {
                        Meter(
                            MeterConfig(
                                majorTicks: 4, minorTicks: 6,
                                bands: [MeterBand(0...0.25, width: 9, opacity: 0.14), MeterBand(0.75...1, width: 9, opacity: 0.14), MeterBand(0.403...0.75, width: 3, opacity: 0.9)],
                                labels: [.init(0, "0"), .init(0.25, "6"), .init(0.5, "12"), .init(0.75, "18"), .init(1, "24")],
                                word: "HOURS", face: .lit, accessibilityLabel: "24-hour meter"
                            ),
                            value: 0.403
                        )
                    }
                }
                group("TwinMeters") {
                    Fascia(nameplate: "Link", timestamp: "Checked 12 s ago") {
                        TwinMeters(
                            left: MeterChannel(.twin(zones: [0.5...1], labels: [.init(0, "0"), .init(0.5, "100"), .init(1, "200")], word: "MS", accessibilityLabel: "Left"), value: 0.1, label: "Left", detail: "Channel 1"),
                            right: MeterChannel(.twin(zones: [0.5...1], labels: [.init(0, "0"), .init(0.5, "100"), .init(1, "200")], word: "MS", accessibilityLabel: "Right"), value: 0.7, label: "Right", detail: "Channel 2")
                        )
                    }
                }
            }
            VStack(alignment: .leading, spacing: 32) {
                group("Verdict · StatusLight") {
                    Verdict("Makes it to reset", message: "A sentence explaining the verdict in plain words.", status: .go, statusLabel: "On pace")
                    HStack(spacing: 14) {
                        StatusLight(.go, "Go")
                        StatusLight(.caution, "Caution")
                        StatusLight(.stop, "Stop")
                        StatusLight(.off, "Off")
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
                group("SectionHeader · Row · Tape") {
                    SectionHeader("Section", detail: "Detail")
                    Row("Plain row", subtitle: "Subtitle", value: "41%", tape: RowTape(0.41))
                    Row("Caution tape", subtitle: "Tinted only when tight", secondary: "18%", tape: RowTape(0.18, status: .caution)) {
                        StatusLight(.caution, "Tight")
                    }
                    Row("Stop tape", value: "97%", valueTone: .hot, tape: RowTape(0.97, status: .stop))
                    Row("Icon row", icon: LetterTile("C"), subtitle: "With secondary value", value: "21%", secondary: "2.1 GB")
                    Row("Selected row", subtitle: "Keyboard focus", options: .selected)
                    Row("Dimmed row with chevron", subtitle: "Opens something", options: [.dimmed, .chevron])
                }
                group("Disclosure · ForecastChart · Sparkline") {
                    Disclosure("Collapsed disclosure", subtitle: "Click to reveal", value: "3") { EmptyView() }
                    Disclosure("Forecast", subtitle: "Full on 26 December", initiallyExpanded: true) {
                        ForecastChart(ForecastConfig(
                            history: GalleryData.diskHistory, lowerBound: 600, limit: 994,
                            startLabel: "Oct 16", endLabel: "Full 26 Dec", limitLabel: "994 GB",
                            accessibilityLabel: "Forecast"
                        ))
                    }
                    Sparkline(GalleryData.diskHistory, accessibilityLabel: "Last 30 days")
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
            }
            VStack(alignment: .leading, spacing: 32) {
                group("PianoKeys · Switch") {
                    SectionHeader("Keep awake")
                    PianoKeys([PanelChoice(0, "Agents"), PanelChoice(1, "1 hour"), PanelChoice(2, "6 PM"), PanelChoice(3, "Always")], selection: .constant(0))
                    Row("Switch on", subtitle: "PanelSwitch") { PanelSwitch(isOn: .constant(true), accessibilityLabel: "On") }
                    Row("Switch off", subtitle: "PanelSwitch") { PanelSwitch(isOn: .constant(false), accessibilityLabel: "Off") }
                }
                group("Field · Tabs · Counter") {
                    Spacer().frame(height: 12)
                    Field(text: .constant(""), prompt: "Search 142 clips", shortcut: "⌘F")
                    Tabs([PanelChoice(0, "All"), PanelChoice(1, "Text"), PanelChoice(2, "Images"), PanelChoice(3, "Links")], selection: .constant(0))
                    Counter("0142", title: "Clips kept", message: "Drum digits with a caption.")
                        .padding(14)
                    HStack(spacing: 12) {
                        DrumDigits("041", small: true)
                        LevelMeter(level: 0.7)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
                group("ChromeBezel · ActionBar · Footer") {
                    Fascia(nameplate: "Frame", timestamp: "Live") {
                        ChromeBezel {
                            CameraPlaceholder().overlay(alignment: .topTrailing) { TallyLight().padding(7) }
                        }
                    }
                    Spacer().frame(height: 10)
                    ActionBar(primary: PanelAction("Primary action") {}, secondary: PanelAction("Second") {})
                    Footer(appName: "App", openSettings: {}, quit: {})
                }
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            Panel(accent: PanelAccent.fuelGauge, content: content)
                .popoverShadow()
        }
    }
}

extension View {
    func popoverShadow() -> some View {
        self
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.black.opacity(0.35), lineWidth: 0.5))
            .compositingGroup()
            .shadow(color: .black.opacity(0.14), radius: 3, y: 2)
            .shadow(color: .black.opacity(0.32), radius: 20, y: 18)
    }
}
