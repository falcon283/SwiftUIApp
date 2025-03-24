import Testing
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView: View {

  @FocusState
  var focused

  var body: some View { EmptyView() }
}

// ❌ @FocusState is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_FocusStateTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_FocusStateTestAbilityChecks {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AnFocusStateInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() async {

    let sut = TestView()

    #expect(sut.focused == false)
    sut.focused = true
    #expect(sut.focused == false, "@FocusState behavior Changed! It was previously not changing from the initial value.")
  }
}
