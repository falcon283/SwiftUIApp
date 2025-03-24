// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let packageConfiguration: (products: [Product], targets: [Target]) = {
  (
    [
      .library(name: "SwiftAppUtilities", targets: ["SwiftAppUtilities"]),
      .library(name: "SwiftUITestSupport", targets: ["SwiftUITestSupport"]),
    ],
    [
      .target(name: "SwiftAppUtilities"),
      .testTarget(name: "SwiftAppUtilitiesTests", dependencies: ["SwiftAppUtilities"]),

      .target(name: "SwiftUITestSupport", dependencies: ["SwiftAppUtilities"]),
      .testTarget(
        name: "SwiftUITestSupportTests",
        dependencies: ["SwiftUITestSupport"]
      )
    ]
  )
}()

let package = Package(
  name: "SwiftUIApp",
  platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1), .macCatalyst(.v13), .macOS(.v10_15)],
  products: packageConfiguration.products,
  targets: packageConfiguration.targets
)
