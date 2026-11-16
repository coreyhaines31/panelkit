import CoreText
import Foundation

/// Entry point for package-wide setup.
public enum PanelKit {
    /// Registers the bundled Barlow Semi Condensed faces for this process. Safe to call more than once.
    @discardableResult
    public static func registerFonts() -> Bool {
        FontRegistry.shared.register()
    }
}

private final class FontRegistry: @unchecked Sendable {
    static let shared = FontRegistry()
    private let lock = NSLock()
    private var registered = false

    func register() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if registered { return true }
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts"), !urls.isEmpty else {
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
}
