// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "meilisearch-vapor",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "MeiliSearchVapor", targets: ["MeiliSearchVapor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "0.15.0"),
    ],
    targets: [
        .target(
            name: "MeiliSearchVapor",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MeiliSearch", package: "meilisearch-swift"),
            ]
        ),
    ]
)
