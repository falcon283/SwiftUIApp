import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct EnvironmentTest {

  @Test
  func Given_Environment_When_CreatedWithNoInjection_Then_ThrowAnError() async throws {

    await #expect(throws: (any Error).self) {
      try await given(TestView()) { sut in
        #expect(sut.customValue == "test")
      }
    }
  }

  @Test
  func Given_Environment_When_Updated_Then_UpdatedValueCanBeRead() async throws {
    try await given(TestView()) {
      $0.environment(\.myCustomValue, "updated")
    } expect: { sut in
      #expect(sut.customValue == "updated")
    }
  }

  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  @Test
  func Given_EnvironmentWithObservable_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestObservableView()) { sut in
      #expect(sut.observableOptional == nil)

      // Commented it's expected to crash if not injected.
      // #expect(sut.observable.value == 0)
    }
  }

  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  @Test
  func Given_EnvironmentWithObservable_When_Updated_Then_UpdatedValueCanBeRead() async throws {
    try await given(TestObservableView()) {
      $0.environment(TestObservable(value: 1))
    } expect: { sut in
      #expect(sut.observableOptional?.value == 1)
      #expect(sut.observable.value == 1)
    }
  }
}

// MARK: - Test Objects

private typealias Environment = SwiftUITestSupport.Environment

private extension EnvironmentValues {
  @Entry var myCustomValue = "test"
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@Observable
private final class TestObservable {

  var value = 0

  init(value: Int = 0) {
    self.value = value
  }
}

private struct TestView: View {

  @Environment(\.myCustomValue)
  var customValue

  var body: some View { EmptyView() }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct TestObservableView: View {

  @Environment(TestObservable.self)
  var observableOptional: TestObservable?

  @Environment(TestObservable.self)
  var observable: TestObservable

  var body: some View { EmptyView() }
}
