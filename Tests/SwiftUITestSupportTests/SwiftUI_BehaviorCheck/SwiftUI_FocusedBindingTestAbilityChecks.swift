import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension FocusedValues {
  @Entry var testValue: Binding<Bool>?
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @FocusedBinding(\.testValue)
  var focused

  var body: some View { EmptyView() }
}

// ❌ @FocusedBinding is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_FocusedBindingTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_FocusedBindingTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AnFocusedBindingInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() async {

    let sut = TestView()

    #expect(sut.focused == nil)
    sut.focused = true
    #expect(sut.focused == nil, "@FocusedBinding behavior Changed! It was previously not changing from the initial value.")
  }
}
