import Testing
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView: View {

  @AccessibilityFocusState
  var focused

  var body: some View { EmptyView() }
}

// ❌ @AccessibilityFocusState is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_AccessibilityFocusStateTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_AccessibilityFocusStateTestAbilityChecks {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AnAccessibilityFocusStateInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() async {

    let sut = TestView()

    #expect(sut.focused == false)
    sut.focused = true
    #expect(sut.focused == false, "@AccessibilityFocusState behavior Changed! It was previously not changing from the initial value.")
  }
}
