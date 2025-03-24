import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct FocusedObjectTests {

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @Test
  func Given_FocusedObject_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testObject == nil)
    }
  }

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @Test
  func Given_FocusedObject_When_Changed_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      $0.focusedObject(TestObject(value: 1))
    } expect: { sut in
      #expect(sut.testObject?.value == 1)
    }
  }
}

// MARK: - Test Objects

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
typealias FocusedObject = SwiftUITestSupport.FocusedObject

private final class TestObject: ObservableObject {

  var value: Int = 0

  init(value: Int) {
    self.value = value
  }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private extension FocusedValues {
  @Entry var myValue: Binding<Bool>?
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TestView: View {

  @FocusedObject
  var testObject: TestObject?

  var body: some View { EmptyView() }
}
