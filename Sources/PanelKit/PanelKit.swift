import AppKit
import CoreText
import Foundation

/// Entry point for package-wide setup.
public enum PanelKit {
    /// Registers the bundled Barlow Semi Condensed faces for this process. Safe to call more than once.
    /// Returns false when the font bundle can't be found; condensed text then uses the system font.
    @discardableResult
    public static func registerFonts() -> Bool {
        FontRegistry.shared.register()
    }
}

final class FontRegistry: @unchecked Sendable {
    static let shared = FontRegistry()
    private static let bundleName = "PanelKit_PanelKit.bundle"
    private let lock = NSLock()
    private var registered = false

    func register() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if registered { return true }
        guard let urls = Self.fontURLs(), !urls.isEmpty else {
            return false
        }
        var allOK = true
        for url in urls {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let code = (error?.takeRetainedValue()).map { CFErrorGetCode($0) } ?? 0
                // kCTFontManagerErrorAlreadyRegistered (105) is fine.
                if code != 105 { allOK = false }
            }
        }
        registered = allOK
        return allOK
    }

    /// The bundled fonts, found without `Bundle.module` (whose generated accessor calls fatalError
    /// when the resource bundle wasn't copied into the app).
    private static func fontURLs() -> [URL]? {
        let anchor = Bundle(for: FontRegistry.self)
        let roots = [
            Bundle.main.resourceURL,
            Bundle.main.bundleURL,
            anchor.resourceURL,
            anchor.bundleURL,
            anchor.bundleURL.deletingLastPathComponent(),
            Bundle.main.executableURL?.deletingLastPathComponent()
        ]
        for root in roots.compactMap({ $0 }) {
            let candidate = root.appendingPathComponent(bundleName)
            if let bundle = Bundle(url: candidate),
               let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts"), !urls.isEmpty {
                return urls
            }
        }
        return nil
    }
}
