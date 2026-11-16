# PanelKit

Shared SwiftUI components for the menu bar popovers, in the Brushed style (brushed aluminium fascia, black anodised in dark mode, cream VU meters, reversed label strips, colour only in status lights, red zones and out-of-range values). Built for a family of free Mac menu bar apps (Fuel Gauge, Spare, Disk Forecast, Midnight Oil, WiFi or ISP, Green Room, On Hand, Coat Check).

![Components, light](docs/gallery/components-light.png)

The package lives at the repo root (`Package.swift`, sources in `Sources/PanelKit`). macOS 14+, Swift 6.

## Add it to an app

In the app's `project.yml` (XcodeGen):

```yaml
packages:
  PanelKit:
    url: https://github.com/coreyhaines31/panelkit
    from: 0.1.0
targets:
  MyApp:
    dependencies:
      - package: PanelKit
```

In a Swift package: `.package(url: "https://github.com/coreyhaines31/panelkit", from: "0.1.0")`, then depend on the `PanelKit` product. Apps built as a bundle by hand must copy `PanelKit_PanelKit.bundle` into `Contents/Resources`; the fonts load from it.

## Register the font

Plates, strips and meter scales use the bundled Barlow Semi Condensed (OFL). Register it once at launch:

```swift
import PanelKit

func applicationDidFinishLaunching(_ notification: Notification) {
    PanelKit.registerFonts()
}
```

Body text uses the system font.

## Minimal popover

```swift
import PanelKit
import SwiftUI

struct FuelPopover: View {
    var body: some View {
        Panel(accent: PanelAccent.fuelGauge) {
            Fascia(nameplate: "Fuel", timestamp: "Updated 9:41 AM", detail: "5-hour window", label: "Claude Code") {
                Meter(
                    MeterConfig(
                        majorTicks: 4, minorTicks: 4, zones: [0...0.12],
                        labels: [.init(0, "E"), .init(0.5, "½"), .init(1, "F")],
                        word: "LIMIT", accessibilityLabel: "Fuel meter"
                    ),
                    value: 0.62, accessibilityValue: "62 percent left"
                )
            }
            Verdict("Makes it to reset", message: "62% left. Resets at 1:00 PM.", status: .go, statusLabel: "On pace")
            SectionHeader("Codex", detail: "Pro plan")
            Row("5-hour window", subtitle: "Runs out around 3:40 PM", secondary: "18%",
                tape: RowTape(0.18, status: .caution)) {
                StatusLight(.caution, "Tight")
            }
            Disclosure("Forecast", subtitle: "Last 30 days") {
                Sparkline([41, 44, 52, 61, 62], accessibilityLabel: "Usage, last 30 days")
                    .padding(.horizontal, 14)
            }
        } footer: {
            Footer(appName: "Fuel Gauge", openSettings: { /* open settings */ }, quit: { NSApp.terminate(nil) })
        }
    }
}
```

`Panel` follows the colour scheme: aluminium in light, anodised with lit amber meters in dark.

## Components

| Component | Use |
|---|---|
| `Panel` | 340 pt container, 12 pt corners, footer slot |
| `Fascia`, `Nameplate`, `LabelStrips`, `BrushedMetal` | Metal header with pilot light, timestamp, instrument and strips |
| `Meter`, `MeterConfig`, `TwinMeters` | VU meter: sweep, ticks, red zones, labels, word, one or more animated needles, cream or lit face |
| `Verdict`, `StatusLight` | Status LED + word, bold title, sentence |
| `SectionHeader`, `Row`, `Tape`, `LetterTile` | Readout rows with value column, tape, selected/dimmed/chevron states |
| `Disclosure` | Expandable row revealing any content |
| `ForecastChart`, `Sparkline` | Past line, dashed projection to a limit, today marker |
| `PianoKeys`, `Tabs`, `PanelChoice` | Segmented choices |
| `PanelSwitch`, `PanelSwitchStyle` | Toggle |
| `ActionBar`, `PanelButtonStyle` | Primary black button + secondary |
| `Field` | Search field with shortcut hint |
| `Counter`, `DrumDigits` | Tape-counter digits |
| `ChromeBezel`, `TallyLight`, `LevelMeter` | Live preview frame, tally, LED level |
| `Footer` | Settings… ⌘, and Quit ⌘Q |
| `PanelTheme`, `PanelAccent`, `PanelStatus` | Colour tokens |

Accessibility: meters, tapes and status lights expose labels and values; needles snap instead of springing under Reduce Motion.

## Gallery

```sh
swift run PanelKitGallery docs/gallery
```

Renders every component and a sample popover per app, light and dark, at 2x. Set `.environment(\.panelSnapshot, true)` when snapshotting your own popovers with `ImageRenderer` so `Field` draws without AppKit.

## Licence

Code: MIT (see `LICENSE`). The bundled Barlow Semi Condensed font is under the SIL Open Font License (`Sources/PanelKit/Resources/Fonts/OFL.txt`).
