import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct StateTests {

  @Test
  func Given_State_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testValue == false)
      #expect(sut.testValueOptional == nil)
    }
  }

  @Test
  func Given_State_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.testValue = true
      sut.testValueOptional = "Test"

      #expect(sut.testValue == true)
      #expect(sut.testValueOptional == "Test")
    }
  }
}

// MARK: - Test Objects

private typealias State = SwiftUITestSupport.State

private struct TestView: View {

  @State
  var testValue: Bool = false

  @State
  var testValueOptional: String?

  var body: some View { EmptyView() }
}
