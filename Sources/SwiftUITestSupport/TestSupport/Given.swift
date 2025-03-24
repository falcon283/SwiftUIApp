public import SwiftUI
private import SwiftAppUtilities

/// An Helper function designed for Unit Testing execution.
///
/// When you a UIFeature is meant to be Unit Tested, It's required to execute the test code wrapped into a ``given(_:withDependencies:expect:)`` call.
///
/// - Parameters:
///   - sut: The System Under Test.
///   - injectDependencies: The Injector object you can use to alter the dependencies.
///   - expect: The actual test to run.
/// - Throws: Throws an error if the given expect function throws an error.
@MainActor
public func given<V: View>(
  _ sut: @autoclosure () -> V,
  withDependencies injectDependencies: (inout Injector) async -> Void = { _ in },
  expect: (V) async throws -> Void
) async throws {

  var injector = Injector()
  await injectDependencies(&injector)

  try await TestSupport.execute(with: injector.storage) {
    try await expect(sut())
  }
}
