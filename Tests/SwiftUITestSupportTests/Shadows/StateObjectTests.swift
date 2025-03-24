import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct StateObjectTests {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_StateObject_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testObject.value == 0)
    }
  }

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_StateObject_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.testObject.value = 1

      #expect(sut.testObject.value == 1)
    }
  }
}

// MARK: - Test Objects

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private typealias StateObject = SwiftUITestSupport.StateObject

private final class TestObject: ObservableObject {

  var value: Int = 0

  init(value: Int = 0) {
    self.value = value
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @StateObject
  var testObject: TestObject = TestObject()

  var body: some View { EmptyView() }
}
