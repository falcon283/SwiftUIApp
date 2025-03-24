import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct AccessibilityFocusStateTests {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AccessibilityFocusState_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testValue == false)
      #expect(sut.testValueOptional == nil)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AccessibilityFocusState_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.testValue = true
      sut.testValueOptional = "Test"

      #expect(sut.testValue == true)
      #expect(sut.testValueOptional == "Test")
    }
  }
}

// MARK: - Test Objects

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private typealias AccessibilityFocusState = SwiftUITestSupport.AccessibilityFocusState

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView: View {

  @AccessibilityFocusState
  var testValue: Bool

  @AccessibilityFocusState
  var testValueOptional: String?

  var body: some View { EmptyView() }
}
