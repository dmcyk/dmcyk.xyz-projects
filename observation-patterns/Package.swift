// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Broadcast",
    dependencies: [
         .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "4.1.2"),
         .package(url: "https://github.com/dmcyk/Console.git", .exact("0.7.1")),
         .package(url: "https://github.com/glessard/swift-atomics.git", from: "4.1.0")
    ],
    targets: [
        .target(
            name: "ObjCConsumer",
            dependencies: ["Atomics"]
        ),
        .target(
            name: "Utility"
        ),
        .target(
            name: "Bench",
            dependencies: ["Utility", "RxSwift", "ObjCConsumer", "Console", "Atomics"]
        ),
        .target(
            name: "Run",
            dependencies: ["Bench"]
        )
    ]
)
