import Testing
import SwiftUI

private final class TestObject: ObservableObject {

  @Published
  var value: Bool

  init(value: Bool) {
    self.value = value
  }
}

@MainActor
private struct TestView: View {

  @ObservedObject
  var object: TestObject

  var body: some View { EmptyView() }
}

// ✅ @ObservedObject is Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_ObservedObjectTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_ObservedObjectTestAbilityChecks {

  @Test
  func Given_AnObservedObjectInAView_When_ValueIsChanged_Then_UpdatedValueCanBeReadBack() async {

    let sut = TestView(object: TestObject(value: false))

    #expect(sut.object.value == false)
    sut.object.value = true
    #expect(sut.object.value == true, "@ObservedObject behavior Changed! It was previously changing from the initial value.")
  }
}
