import Testing
import SwiftUI
import SwiftAppUtilities
import SwiftUITestSupport

@MainActor
@Suite
struct FocusStateTests {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FocusState_Value_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testBool == false)
      #expect(sut.testOptional == nil)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FocusState_Value_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.testBool = true
      sut.testOptional = "test"

      #expect(sut.testBool == true)
      #expect(sut.testOptional == "test")
    }
  }
}

// MARK: - Test Objects

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private typealias FocusState = SwiftUITestSupport.FocusState

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView: View {

  @FocusState
  var testBool: Bool

  @FocusState
  var testOptional: String?

  var body: some View { EmptyView() }
}
