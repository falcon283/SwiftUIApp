import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension FocusedValues {
  @Entry var testValue: Int?
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @FocusedValue(\.testValue)
  var value: Int?

  var body: some View { EmptyView() }
}

// ❌ @FocusedValue is not Testable.
// It must be shadowed since the values are provided by the view using
// .focusedValue(...)
// .focusedSceneValue(...)

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_FocusedValueTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_FocusedValueTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AnFocusedValueInAView_When_ObjectIsNil_Then_CanBeInspectedAsNilButCannotBeChanged() async {

    let sut = TestView()

    #expect(sut.value == nil, "@FocusedValue behavior Changed!")
  }
}
