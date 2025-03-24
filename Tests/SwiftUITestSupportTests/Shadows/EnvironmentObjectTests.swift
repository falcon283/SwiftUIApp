import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct EnvironmentObjectTest {

  @Test
  func Given_EnvironmentObject_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      // Commented it's expected to crash if not injected.
      // #expect(sut.observableObject.value == 0)
    }
  }

  @Test
  func Given_EnvironmentObject_When_Injected_Then_UpdatedValueCanBeRead() async throws {
    try await given(TestView()) {
      $0.environmentObject(TestObservableObject(value: 1))
    } expect: { sut in
      #expect(sut.observableObject.value == 1)
    }
  }
}

// MARK: - Test Objects

private typealias EnvironmentObject = SwiftUITestSupport.EnvironmentObject

private final class TestObservableObject: ObservableObject {

  var value = 0

  init(value: Int = 0) {
    self.value = value
  }
}

@MainActor
private struct TestView: View {

  @EnvironmentObject
  var observableObject: TestObservableObject

  var body: some View { EmptyView() }
}
