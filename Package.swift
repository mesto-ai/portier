// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PortMonitor",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PortMonitor",
            path: "PortMonitor",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "PortMonitor/Info.plist"])
            ]
        )
    ]
)
