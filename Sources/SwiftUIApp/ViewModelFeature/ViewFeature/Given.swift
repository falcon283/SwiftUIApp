import SwiftUITestSupport

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
