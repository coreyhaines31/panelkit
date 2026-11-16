import AppKit
import PanelKit
import SwiftUI

// Renders every PanelKit component and a sample popover for each app to PNG, in light and dark.
// Usage: swift run PanelKitGallery <output-folder>

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: PanelKitGallery <output-folder>\n".utf8))
    exit(2)
}
let output = URL(fileURLWithPath: arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

guard PanelFont.register() else {
    FileHandle.standardError.write(Data("could not register Barlow Semi Condensed\n".utf8))
    exit(1)
}

struct Backdrop<Content: View>: View {
    let scheme: ColorScheme
    let content: Content

    var body: some View {
        content
            .padding(40)
            .background(scheme == .dark ? Color(hex: 0x0C0C0D) : Color(hex: 0xCDCECD))
            .environment(\.colorScheme, scheme)
            .environment(\.panelSnapshot, true)
    }
}

@MainActor
func render<V: View>(_ view: V, scheme: ColorScheme, to name: String) throws {
    let renderer = ImageRenderer(content: Backdrop(scheme: scheme, content: view))
    renderer.scale = 2
    guard let image = renderer.cgImage else {
        throw NSError(domain: "PanelKitGallery", code: 1, userInfo: [NSLocalizedDescriptionKey: "render failed: \(name)"])
    }
    let bitmap = NSBitmapImageRep(cgImage: image)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "PanelKitGallery", code: 2, userInfo: [NSLocalizedDescriptionKey: "encode failed: \(name)"])
    }
    let url = output.appendingPathComponent("\(name).png")
    try data.write(to: url)
    print(url.path)
}

for (scheme, suffix) in [(ColorScheme.light, "light"), (ColorScheme.dark, "dark")] {
    try render(ComponentSheet(), scheme: scheme, to: "components-\(suffix)")
    try render(AdditionsSheet(), scheme: scheme, to: "additions-\(suffix)")
    for sample in AppSamples.all {
        try render(sample.view.popoverShadow(), scheme: scheme, to: "\(sample.slug)-\(suffix)")
    }
    let samples = AppSamples.all
    let sheet = VStack(alignment: .leading, spacing: 40) {
        ForEach(Array(stride(from: 0, to: samples.count, by: 3)), id: \.self) { start in
            HStack(alignment: .top, spacing: 32) {
                ForEach(start..<min(start + 3, samples.count), id: \.self) { index in
                    samples[index].view.popoverShadow()
                }
            }
        }
    }
    try render(sheet, scheme: scheme, to: "popovers-\(suffix)")
}
