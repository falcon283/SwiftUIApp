// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// MARK: Configurations

let testSupportEnabled = ProcessInfo().environment["SWIFTUIAPP_TEST_SUPPORT"] == "TRUE"

let canTestSwiftUISettings: [SwiftSetting]? = !testSupportEnabled ? nil : [
  .define("canTestSwiftUI", .when(configuration: .debug))
]

// MARK: - Modules Definition

enum Module: String, CaseIterable {
  case swiftUIApp = "SwiftUIApp"
  case swiftUITestSupport = "SwiftUITestSupport"
  case swiftAppUtilities = "SwiftAppUtilities"
}

// MARK: - Package Definition

let package = Package(
  name: "SwiftUIApp Toolkit",
  platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1), .macCatalyst(.v13), .macOS(.v10_15)],
  products: Module.allCases.map(\.product),
  dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.4")],
  targets: Module.allCases.map(\.targets).flatMap { $0 }
)

// MARK: - Modules Implementations

extension Module {

  var libraryName: String {
    self.rawValue
  }

  var targetName: String {
    self.libraryName
  }

  var targetDependency: Target.Dependency {
    .init(stringLiteral: self.targetName)
  }

  var testTargetName: String {
    return self.targetName + "Tests"
  }
}

extension Module {

  var product: Product {
    switch self {
    case .swiftUIApp:
      return .library(name: Module.swiftUIApp.libraryName, targets: [Module.swiftUIApp.targetName])
    case .swiftUITestSupport:
      return .library(name: Module.swiftUITestSupport.libraryName, targets: [Module.swiftUITestSupport.targetName])
    case .swiftAppUtilities:
      return .library(name: Module.swiftAppUtilities.libraryName, targets: [Module.swiftAppUtilities.targetName])
    }
  }

  var targets: [Target] {
    switch self {
    case .swiftUIApp:
      return [
        .target(
          name: Module.swiftUIApp.targetName,
          dependencies: [Module.swiftAppUtilities, Module.swiftUITestSupport].map(\.targetDependency),
          swiftSettings: canTestSwiftUISettings
        ),
        .testTarget(
          name: Module.swiftUIApp.testTargetName,
          dependencies: [Module.swiftUIApp.targetDependency],
          swiftSettings: canTestSwiftUISettings
        )
      ]

    case .swiftUITestSupport:
      return [
        .target(
          name: Module.swiftUITestSupport.targetName,
          dependencies: [Module.swiftAppUtilities.targetDependency],
          swiftSettings: canTestSwiftUISettings
        ),
        .testTarget(
          name: Module.swiftUITestSupport.testTargetName,
          dependencies: [Module.swiftUITestSupport.targetDependency],
          resources: [.process("CoreData/TestModel.xcdatamodeld")],
          swiftSettings: canTestSwiftUISettings
        )
      ]

    case .swiftAppUtilities:
      return [
        .target(name: Module.swiftAppUtilities.targetName),
        .testTarget(
          name: Module.swiftAppUtilities.testTargetName,
          dependencies: [Module.swiftAppUtilities.targetDependency]
        )
      ]
    }
  }
}
