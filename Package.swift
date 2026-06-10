// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TimerStack",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TimerStack",
            path: "Sources/TimerStack"
        )
    ]
)
