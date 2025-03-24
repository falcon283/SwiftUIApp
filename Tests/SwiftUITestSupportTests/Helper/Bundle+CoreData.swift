import Foundation

extension Bundle {

  static let coreDataTestBundle: Bundle = {

    final class BundleDiscovery { }
    let unitTestBundle = Bundle(for: BundleDiscovery.self)

    let coreDataBungle = Bundle(
      path: unitTestBundle.path(forResource: "SwiftUIApp_SwiftUITestSupportTests", ofType: "bundle")!
    )!

    return coreDataBungle
  }()
}
