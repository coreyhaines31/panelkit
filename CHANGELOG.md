# Changelog

## Unreleased
- README credits the vintage Sony tape decks that inspired the Brushed look.

## 0.2.0

Pieces the eight apps built locally while adopting 0.1, moved into PanelKit (#1).

### Added

- `MenuCard` and `NSMenuItem.panelCard(_:)`: the Brushed card at the top of a native menu (330 pt inset 5 pt in a 340 pt menu, 7 pt corners, hairline ring), with `appearance: .dark` for an always-dark card.
- `Fascia`: `isLit` (pilot light off), `leadingAccessory` and `trailingAccessory` header slots; an empty nameplate draws none.
- `KeyCap` and `KeyCapStyle`: 20 pt metal keys for fascia toolbars.
- `PanelButtonStyle`: `.compact` size and `.destructive` kind; `.panelPrimary`, `.panelSecondary`, `.panelCompact`, `.panelDestructive` shorthands.
- `PanelLinkStyle` (accent or quiet) and `LinkBar`.
- `PanelTheme.link`: #2f63d3 light, #8fb0ff dark.
- `Row.subtitleLineLimit(_:)`, `Row.trailingAccessory(_:)`, `SymbolTile`.
- `Tape(_:projection:status:)` and `RowTape.projection`: a faint segment to a projected value.
- `Disclosure.subtitleTint(_:)` and `Disclosure.trailingAccessory(_:)`.
- `SectionHeader(_:actionTitle:action:)` and `SectionHeader.trailingAccessory(_:)`.
- `Notice`, `NumberedSteps`/`NumberedStep`, `ConfirmBox`, `Recess`, `ReadingTile`, `TipStrip`.
- `StatusLED`: the bare status lamp.
- `LevelMeter(stopFrom:)`: stop-coloured top segments.
- `ForecastConfig(points:projection:domain:...)` with `ForecastPoint` for dated readings; `startValueLabel` and `todayValueLabel`; `historyPositions` and `projectionPosition`.
- `Panel(accent:fillsHeight:)` for fixed-height windows.
- `NativeSearchField`: the Field well around an `NSSearchField` with ↑↓, Return, Esc and focus requests.
- `VerdictView` and `PanelForecastChart` aliases.
- `PanelFont.register()`.
- `EnvironmentValues.panelTheme` is public.

### Changed

- `ForecastChart` hides the Today label when it would collide with the start or end label.
- Fonts are found without `Bundle.module`, so a missing `PanelKit_PanelKit.bundle` no longer crashes; condensed text falls back to the condensed system font.

### Deprecated

- `PanelKit.registerFonts()`: use `PanelFont.register()`. The `PanelKit` enum is removed so the module name can qualify types (`PanelKit.Verdict`); the old spelling compiles via a deprecated module-level function until 0.3.

## 0.1.0

First release: Panel, Fascia, Meter, TwinMeters, Verdict, StatusLight, SectionHeader, Row, Tape, Disclosure, ForecastChart, Sparkline, PianoKeys, Tabs, PanelSwitch, ActionBar, Field, Counter, ChromeBezel, LevelMeter, Footer and the Brushed theme.
