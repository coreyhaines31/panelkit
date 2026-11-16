import PanelKit
import SwiftUI

/// A sample popover for one app, rendered by the gallery.
struct AppSample {
    let slug: String
    let name: String
    let view: AnyView
}

@MainActor
private func footer(_ app: String) -> Footer {
    Footer(appName: app, openSettings: {}, quit: {})
}

@MainActor
enum AppSamples {
    static var all: [AppSample] { [
        AppSample(slug: "fuel-gauge", name: "Fuel Gauge", view: AnyView(fuelGauge)),
        AppSample(slug: "spare", name: "Spare", view: AnyView(spare)),
        AppSample(slug: "disk-forecast", name: "Disk Forecast", view: AnyView(diskForecast)),
        AppSample(slug: "midnight-oil", name: "Midnight Oil", view: AnyView(midnightOil)),
        AppSample(slug: "wifi-or-isp", name: "WiFi or ISP", view: AnyView(wifiOrISP)),
        AppSample(slug: "green-room", name: "Green Room", view: AnyView(greenRoom)),
        AppSample(slug: "on-hand", name: "On Hand", view: AnyView(onHand)),
        AppSample(slug: "coat-check", name: "Coat Check", view: AnyView(coatCheck)),
        AppSample(slug: "disk-forecast-low", name: "Disk Forecast (low disk)", view: AnyView(diskForecastLow))
    ] }

    static var fuelGauge: some View {
        Panel(accent: PanelAccent.fuelGauge) {
            Fascia(nameplate: "Fuel", timestamp: "Updated 9:41 AM", detail: "5-hour window", label: "Claude Code") {
                Meter(
                    MeterConfig(
                        majorTicks: 4, minorTicks: 4, zones: [0...0.12],
                        labels: [.init(0, "E"), .init(0.25, "¼"), .init(0.5, "½"), .init(0.75, "¾"), .init(1, "F")],
                        innerLabels: [.init(0, "0"), .init(0.5, "50"), .init(1, "100%")],
                        word: "LIMIT", accessibilityLabel: "Fuel meter"
                    ),
                    value: 0.62, accessibilityValue: "62 percent left"
                )
            }
            Verdict("Makes it to reset", message: "62% left. The window resets at 1:00 PM with about 31% to spare.", status: .go, statusLabel: "On pace")
            SectionHeader("Claude Code", detail: "Max plan")
            Row("Weekly", subtitle: "Resets Thursday 9:00 AM", value: "41%", tape: RowTape(0.41))
            SectionHeader("Codex", detail: "Pro plan")
            Row("5-hour window", subtitle: "Runs out around 3:40 PM, 1 h 20 m early", secondary: "18%", tape: RowTape(0.18, status: .caution)) {
                StatusLight(.caution, "Tight")
            }
            SectionHeader("Grok")
            Row("Daily window", subtitle: "Resets 6:00 PM", value: "88%", tape: RowTape(0.88))
        } footer: {
            footer("Fuel Gauge")
        }
    }

    static var spare: some View {
        Panel(accent: PanelAccent.spare) {
            Fascia(nameplate: "Load", timestamp: "Updated 9:41 AM", detail: "×10 percent", label: "This Mac") {
                Meter(
                    MeterConfig(
                        majorTicks: 10, minorTicks: 2, zones: [0.8...1],
                        labels: [.init(0, "0"), .init(0.2, "2"), .init(0.4, "4"), .init(0.6, "6"), .init(0.8, "8"), .init(1, "10")],
                        word: "LOAD", accessibilityLabel: "Load meter"
                    ),
                    value: 0.38
                )
            }
            Verdict("38% load", message: "3 agents and 14 apps are running.", status: .go, statusLabel: "Comfortable")
            SectionHeader("Using the most", detail: "CPU · memory")
            Row("Claude Code", icon: LetterTile("C"), subtitle: "~/code/spare · agent", value: "21%", secondary: "2.1 GB")
            Row("Google Chrome", icon: LetterTile("G"), subtitle: "38 tabs, 6 extensions", value: "9%", secondary: "3.4 GB")
            Row("Docker", icon: LetterTile("D"), subtitle: "4 containers", value: "6%", secondary: "4.0 GB")
            SectionHeader("Strays")
            Row("2 processes outlived their agent", subtitle: "node, esbuild · 1.8 GB") {
                StatusLight(.caution, "Review")
            }
        } footer: {
            footer("Spare")
        }
    }

    static let diskMeter = MeterConfig(
        majorTicks: 5, minorTicks: 4, zones: [0.9...1],
        labels: [.init(0, "0"), .init(0.2, "20"), .init(0.4, "40"), .init(0.6, "60"), .init(0.8, "80"), .init(1, "100")],
        word: "% FULL", wordSize: 20, accessibilityLabel: "Disk meter"
    )

    static var diskForecast: some View {
        Panel(accent: PanelAccent.diskForecast) {
            Fascia(nameplate: "Disk", timestamp: "Updated 9:41 AM", detail: "214 GB free of 994 GB", label: "Macintosh HD") {
                Meter(diskMeter, value: 0.784, accessibilityValue: "78 percent full")
            }
            Counter("041", title: "Days to full", message: "Full on 26 December at about 5.1 GB a day.")
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            ForecastChart(ForecastConfig(
                history: GalleryData.diskHistory, lowerBound: 600, limit: 994,
                startLabel: "Oct 16", endLabel: "Full 26 Dec", limitLabel: "994 GB",
                accessibilityLabel: "Disk usage over 30 days, forecast full on 26 December"
            ))
            SectionHeader("Reclaimable", detail: "69.7 GB")
            Row("Xcode build files", subtitle: "DerivedData · safe to remove", value: "38.2 GB")
            Row("Docker images", subtitle: "11 images no container uses", value: "22.4 GB")
        } footer: {
            footer("Disk Forecast")
        }
    }

    static var diskForecastLow: some View {
        Panel(accent: PanelAccent.diskForecast) {
            Fascia(nameplate: "Disk", timestamp: "Updated 8:02 PM", detail: "31 GB free of 994 GB", label: "Macintosh HD") {
                Meter(diskMeter, value: 0.969, accessibilityValue: "97 percent full")
            }
            Counter("009", title: "Days to full", message: "Full on 24 November. Docker grew 40 GB this week.", messageIsAlarm: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            SectionHeader("Biggest change")
            Row("Docker images", subtitle: "Up 40 GB since Monday", value: "62.4 GB", valueTone: .hot)
            Disclosure("30-day forecast", subtitle: "Full on 24 November") {
                ForecastChart(ForecastConfig(
                    history: GalleryData.diskHistory.map { $0 + 180 }, lowerBound: 600, limit: 994,
                    todayPosition: 0.8, startLabel: "Oct 16", endLabel: "Full 24 Nov", limitLabel: "994 GB",
                    accessibilityLabel: "Disk usage, forecast full on 24 November"
                ))
            }
            ActionBar(primary: PanelAction("Explain Docker usage") {})
        } footer: {
            footer("Disk Forecast")
        }
    }

    static var midnightOil: some View {
        Panel(accent: PanelAccent.midnightOil) {
            Fascia(nameplate: "Awake", timestamp: "Since 7:12 AM", detail: "Awake until 6:00 PM", label: "Claude Code") {
                Meter(
                    MeterConfig(
                        majorTicks: 4, minorTicks: 6,
                        bands: [MeterBand(0...0.25, width: 9, opacity: 0.14), MeterBand(0.75...1, width: 9, opacity: 0.14), MeterBand(0.403...0.75, width: 3, opacity: 0.9)],
                        labels: [.init(0, "0"), .init(0.25, "6"), .init(0.5, "12"), .init(0.75, "18"), .init(1, "24")],
                        word: "HOURS", accessibilityLabel: "24-hour meter"
                    ),
                    value: 0.403, accessibilityValue: "Awake until 6 PM"
                )
            }
            Verdict("Awake until 6:00 PM", message: "Because Claude Code is running in ~/code/spare.", status: .go, statusLabel: "Keeping awake")
            SectionHeader("Keep awake")
            PianoKeys(
                [PanelChoice("agents", "Agents"), PanelChoice("1h", "1 hour"), PanelChoice("6pm", "6 PM"), PanelChoice("always", "Always")],
                selection: .constant("agents")
            )
            Row("Let the display sleep", subtitle: "The Mac stays awake, the screen can turn off") {
                PanelSwitch(isOn: .constant(true), accessibilityLabel: "Let the display sleep")
            }
            Row("Stay awake with the lid closed", subtitle: "Only while plugged in") {
                PanelSwitch(isOn: .constant(false), accessibilityLabel: "Stay awake with the lid closed")
            }
            ActionBar(primary: PanelAction("Stop keeping awake") {})
        } footer: {
            footer("Midnight Oil")
        }
    }

    static var wifiOrISP: some View {
        let scale = MeterConfig.twin(
            zones: [0.5...1],
            labels: [.init(0, "0"), .init(0.25, "50"), .init(0.5, "100"), .init(1, "200")],
            word: "MS", accessibilityLabel: "Latency meter"
        )
        var wifi = scale
        wifi.accessibilityLabel = "Wi-Fi meter"
        var isp = scale
        isp.accessibilityLabel = "ISP meter"
        return Panel(accent: PanelAccent.wifiOrISP) {
            Fascia(nameplate: "Link", timestamp: "Checked 12 s ago") {
                TwinMeters(
                    left: MeterChannel(wifi, value: 0.015, accessibilityValue: "3 milliseconds", label: "Wi-Fi", detail: "Your side"),
                    right: MeterChannel(isp, value: 0.74, accessibilityValue: "148 milliseconds", label: "ISP", detail: "Their side")
                )
            }
            Verdict("It’s your ISP", message: "Wi-Fi is fine. Past your router, 4% of packets are lost.", status: .stop, statusLabel: "ISP")
            SectionHeader("Your side", detail: "Wi-Fi")
            Row("Signal", subtitle: "Office-5G · channel 149", value: "−52 dBm", secondary: "Great")
            Row("Router", subtitle: "192.168.1.1", value: "3 ms", secondary: "Great")
            SectionHeader("Their side", detail: "ISP")
            Row("First hop", subtitle: "Cox · 68.105.28.11", value: "148 ms", valueTone: .hot, secondary: "Slow")
            Row("Packet loss", subtitle: "Last 2 minutes", value: "4.2%", valueTone: .hot, secondary: "High")
            ActionBar(primary: PanelAction("Copy report for your ISP") {}, secondary: PanelAction("Retest") {})
        } footer: {
            footer("WiFi or ISP")
        }
    }

    static var greenRoom: some View {
        Panel(accent: PanelAccent.greenRoom) {
            Fascia(nameplate: "Frame", timestamp: "Call in 5 min", detail: "Level within 0.4°", label: "Camera") {
                ChromeBezel {
                    CameraPlaceholder()
                        .overlay(alignment: .topTrailing) { TallyLight().padding(7) }
                }
            }
            Verdict("AirPods took over the speaker", message: "Everything else matches your Studio setup.", status: .caution, statusLabel: "1 to fix")
            SectionHeader("Studio setup")
            Row("Camera", icon: SymbolIcon("video"), subtitle: "ZV-E10 via Cam Link 4K") {
                StatusLight(.go, "Matches")
            }
            Row("Microphone", icon: SymbolIcon("mic"), subtitle: "Shure MV7") {
                LevelMeter(level: 0.75)
            }
            Row("Speaker", icon: SymbolIcon("speaker.wave.2"), subtitle: "AirPods Pro · expected Studio Display") {
                StatusLight(.caution, "Changed")
            }
            ActionBar(primary: PanelAction("Switch to Studio Display") {}, secondary: PanelAction("Test tone") {})
        } footer: {
            footer("Green Room")
        }
    }

    static var onHand: some View {
        Panel(accent: PanelAccent.onHand) {
            Fascia(nameplate: "Clips", timestamp: "9:41 AM") {
                Counter("0142", title: "Clips kept", message: "Since Monday. Passwords and card numbers are skipped.")
            }
            Spacer().frame(height: 12)
            Field(text: .constant(""), prompt: "Search 142 clips", shortcut: "⌘F")
            Tabs(
                [PanelChoice(0, "All"), PanelChoice(1, "Text"), PanelChoice(2, "Images"), PanelChoice(3, "Links"), PanelChoice(4, "Pinned")],
                selection: .constant(0)
            )
            Row("git push -u origin feature/1-brand-foundation", subtitle: "Ghostty · 2 m ago", options: [.selected, .monospacedName]) {
                ShortcutHint("⌘1")
            }
            Row("diskforecast.com/changelog", subtitle: "Safari · link · 6 m ago") { ShortcutHint("⌘2") }
            Row("Screenshot 2026-11-15 at 9.31", icon: ThumbPlaceholder(), subtitle: "Image · 1280 × 800 · 10 m ago") {
                ShortcutHint("⌘3")
            }
            Row("Ship it Monday, then the site.", subtitle: "Messages · 24 m ago") { ShortcutHint("⌘4") }
            Row("Password skipped", subtitle: "From 1Password · never saved", options: .dimmed) { ShortcutHint("—") }
        } footer: {
            footer("On Hand")
        }
    }

    static var coatCheck: some View {
        Panel(accent: PanelAccent.coatCheck) {
            Fascia(nameplate: "Icons", timestamp: "14 in the menu bar", detail: "Bearing", label: "Menu bar") {
                Meter(
                    MeterConfig(
                        majorTicks: 4, minorTicks: 4, zones: [0.47...0.53],
                        labels: [.init(0, "W"), .init(0.25, "NW"), .init(0.5, "N"), .init(0.75, "NE"), .init(1, "E")],
                        word: "NOTCH", accessibilityLabel: "Bearing meter"
                    ),
                    value: 0.5, accessibilityValue: "Pointing north, at the notch"
                )
            }
            Verdict("3 icons hidden by the notch", message: "Click one to open it in place. Apps with menus open right here.", status: .caution, statusLabel: "3 hidden")
            SectionHeader("No room in the menu bar", detail: "3")
            Row("Tailscale", icon: LetterTile("T"), subtitle: "Connected · has a menu", options: .chevron)
            Row("1Password", icon: LetterTile("1"), subtitle: "Locked · has a menu", options: .chevron)
            Row("Raycast", icon: LetterTile("R"), subtitle: "Opens in place")
            SectionHeader("In the menu bar", detail: "11")
            Row("Fuel Gauge", icon: SymbolIcon("gauge.with.needle"), subtitle: "62% left")
            Row("10 more", options: [.dimmed, .chevron])
        } footer: {
            footer("Coat Check")
        }
    }
}

/// Gallery-only stand-ins for app content.
struct CameraPlaceholder: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(white: 0.24), location: 0),
                    .init(color: Color(white: 0.32), location: 0.58),
                    .init(color: Color(white: 0.18), location: 0.582),
                    .init(color: Color(white: 0.14), location: 1)
                ],
                startPoint: .top, endPoint: .bottom
            )
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(colors: [Color(white: 0.67), Color(white: 0.81)], startPoint: .top, endPoint: .bottom))
                    .opacity(0.75)
                    .frame(width: w * 0.26, height: h * 0.4)
                    .position(x: w * 0.21, y: h * 0.32)
                Path { path in
                    for x in [w / 3, 2 * w / 3] {
                        path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: h))
                    }
                    for y in [h / 3, 2 * h / 3] {
                        path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: w, y: y))
                    }
                }
                .stroke(.white.opacity(0.2), lineWidth: 0.6)
                Path { path in
                    path.move(to: CGPoint(x: w * 0.04, y: h * 0.507)); path.addLine(to: CGPoint(x: w * 0.14, y: h * 0.502))
                    path.move(to: CGPoint(x: w * 0.86, y: h * 0.493)); path.addLine(to: CGPoint(x: w * 0.96, y: h * 0.489))
                    path.move(to: CGPoint(x: w * 0.44, y: h * 0.5)); path.addLine(to: CGPoint(x: w * 0.475, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.54)); path.addLine(to: CGPoint(x: w * 0.525, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.5))
                }
                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct ThumbPlaceholder: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0xCDCFD0)))
            var path = Path()
            var x: CGFloat = -size.height
            while x < size.width {
                path.move(to: CGPoint(x: x, y: size.height)); path.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += 8
            }
            context.stroke(path, with: .color(Color(hex: 0xA9ABAD)), lineWidth: 4)
        }
        .frame(width: 22, height: 22)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct SymbolIcon: View {
    let name: String
    init(_ name: String) { self.name = name }
    var body: some View {
        Image(systemName: name)
            .font(.system(size: 13, weight: .regular))
            .frame(width: 22, height: 22)
    }
}

struct ShortcutHint: View {
    let text: String
    @Environment(\.colorScheme) private var scheme
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 11.5))
            .monospacedDigit()
            .foregroundStyle(scheme == .dark ? Color(hex: 0xC6C7C8) : Color(hex: 0x3D3F41))
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

enum GalleryData {
    /// 31 days of disk use from 708 GB to 780 GB with a little noise (same generator as the HTML reference).
    static let diskHistory: [Double] = {
        var seed = 7.0
        return (0...30).map { index in
            seed = (seed * 9301 + 49297).truncatingRemainder(dividingBy: 233280)
            return 708 + (780 - 708) * Double(index) / 30 + (seed / 233280 - 0.5) * 6
        }
    }()
}
