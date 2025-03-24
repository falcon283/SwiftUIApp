import Testing
import SwiftUI
import SwiftAppUtilities
import SwiftUITestSupport

@MainActor
@Suite
struct FocusedValueTests {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_FocusedValue_Value_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testValue == nil)
    }
  }

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_FocusedValue_Value_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      $0.focusedValue(\.myValue, .init(get: { true }, set: { _ in }))
    } expect: { sut in
      #expect(sut.testValue?.wrappedValue == true)
    }
  }

  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  @Test
  func Given_FocusedValueObservable_Value_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestViewObservable()) { sut in
      #expect(sut.testValue == nil)
    }
  }

  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  @Test
  func Given_FocusedValueObservable_Value_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestViewObservable()) {
      $0.focusedValue(TestObject(value: 1))
    } expect: { sut in
      #expect(sut.testValue?.value == 1)
    }
  }
}

// MARK: - Test Objects

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private typealias FocusedValue = SwiftUITestSupport.FocusedValue

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension FocusedValues {
  @Entry var myValue: Binding<Bool>?
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @FocusedValue(\.myValue)
  var testValue

  var body: some View { EmptyView() }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
private final class TestObject {

  var value: Int = 0

  init(value: Int = 0) {
    self.value = value
  }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct TestViewObservable: View {

  @FocusedValue(TestObject.self)
  var testValue

  var body: some View { EmptyView() }
}
