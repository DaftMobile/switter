// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Switter",
    targets: [
        Target(name: "Models"),
        Target(name: "Logic", dependencies: ["Models"]),
        Target(name: "Run", dependencies: ["Models", "Logic"])
        ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor-community/swiftybeaver-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 2),
        ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Flockfile.swift"
    ]
)
