// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "TimerStack",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "TimerStack",
            path: "Sources/TimerStack",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
