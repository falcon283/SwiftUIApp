import Testing
import SwiftUI

private final class TestObject: ObservableObject {

  @Published
  var value = 10
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
private struct TestView: View {

  @FocusedObject
  var object: TestObject?

  var body: some View { EmptyView() }
}

// ❌ @FocusedObject is not Testable.
// It must be shadowed since the values are provided by the view using
// .focusedObject(...)
// .focusedSceneObject(...)

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_FocusedObjectTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_FocusedObjectTestAbilityChecks {

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @Test
  func Given_AFocusedObjectInAView_When_ObjectIsNil_Then_CanBeInspectedAsNilButCannotBeChanged() async {

    let sut = TestView()

    #expect(sut.object == nil, "@FocusedObject behavior Changed!")
  }
}
