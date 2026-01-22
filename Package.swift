// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "candle-swift-distributed-tracing",
    products: [
        .library(name: "CandleInstrumentation", targets: ["CandleInstrumentation"]),
        .library(name: "CandleTracing", targets: ["CandleTracing"]),
    ],
    dependencies: [
        .package(name: "candle-swift-service-context", url: "https://github.com/candlefinance/swift-service-context.git", branch: "fix-candle-1.2.1")
    ],
    targets: [
        // ==== --------------------------------------------------------------------------------------------------------
        // MARK: Instrumentation

        .target(
            name: "CandleInstrumentation",
            dependencies: [
                .product(name: "CandleServiceContextModule", package: "candle-swift-service-context")
            ]
        ),
        .testTarget(
            name: "InstrumentationTests",
            dependencies: [
                .target(name: "CandleInstrumentation")
            ]
        ),

        // ==== --------------------------------------------------------------------------------------------------------
        // MARK: Tracing

        .target(
            name: "CandleTracing",
            dependencies: [
                .product(name: "CandleServiceContextModule", package: "candle-swift-service-context"),
                .target(name: "CandleInstrumentation"),
                .target(name: "Candle_CWASI", condition: .when(platforms: [.wasi])),
            ]
        ),
        .testTarget(
            name: "TracingTests",
            dependencies: [
                .target(name: "CandleTracing")
            ]
        ),

        // ==== --------------------------------------------------------------------------------------------------------
        // MARK: Wasm Support

        // Provides C shims for compiling to wasm
        .target(
            name: "Candle_CWASI",
            dependencies: []
        ),
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency=complete"))
    target.swiftSettings = settings
}
