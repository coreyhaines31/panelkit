// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PanelKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PanelKit", targets: ["PanelKit"])
    ],
    targets: [
        .target(
            name: "PanelKit",
            resources: [.copy("Resources/Fonts")]
        ),
        .executableTarget(
            name: "PanelKitGallery",
            dependencies: ["PanelKit"]
        )
    ]
)
