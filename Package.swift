// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LRNotificationObserver",
    products: [
        .library(
            name: "LRNotificationObserver",
            targets: ["LRNotificationObserver"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LRNotificationObserver",
            path: "LRNotificationObserver",
            publicHeadersPath: ""),
    ]
)
