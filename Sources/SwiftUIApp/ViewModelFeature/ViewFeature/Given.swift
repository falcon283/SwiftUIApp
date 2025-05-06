import SwiftUITestSupport

/// An Helper function designed for Unit Testing execution.
///
/// This function is meant to be used as helper for testing a ``ViewFeature`` if the test requires to use the
/// synchronous ``ViewModelFeature/notify(_:with:storedIn:)``
///
/// - Parameters:
///   - sut: The System Under Test.
///   - injectDependencies: The Injector object you can use to alter the dependencies.
///   - expect: The actual test to run.
/// - Throws: Throws an error if the given expect function throws an error.
@MainActor
internal func given<V: ViewFeature>(
  _ sut: @autoclosure () -> V,
  withDependencies injectDependencies: (inout Injector) async throws -> Void = { _ in },
  expect: @MainActor (V, CancellationBag) async throws -> Void
) async throws {

  let bag = CancellationBag()
  try await SwiftUITestSupport.given(sut(), withDependencies: injectDependencies) { sut in
    try await expect(sut, bag)
  }
}
