import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct FocusedBindingTests {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_FocusedBinding_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testValue == nil)
    }
  }

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_FocusedBinding_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.testValue = true

      #expect(sut.testValue == true)
    }
  }
}

// MARK: - Test Objects

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
typealias FocusedBinding = SwiftUITestSupport.FocusedBinding

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension FocusedValues {
  @Entry var myValue: Binding<Bool>?
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @FocusedBinding(\.myValue)
  var testValue

  var body: some View { EmptyView() }
}
