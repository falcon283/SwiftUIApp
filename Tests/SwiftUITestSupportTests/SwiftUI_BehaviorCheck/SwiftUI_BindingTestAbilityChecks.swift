import Testing
import SwiftUI
import SwiftAppUtilities

private struct TestView: View {

  @Binding
  var binding: Bool

  var body: some View { EmptyView() }
}

// ✅ @Binding is Testable.
// Also we don't need to Shadow since SwiftUIApp is banning Vanilla SwiftUI Bindings so to centralize the Business logic
// using ViewModelFeature derived Binding.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_BindingTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_BindingTestAbilityChecks {

  @Test
  func Given_AnBindingInAView_When_ValueIsChanged_Then_UpdatedValueCanBeReadBack() async {

    let threadSafe = ThreadSafe(false)
    let sut = TestView(
      binding: Binding(
        get: { threadSafe.wrappedValue },
        set: { threadSafe.projectedValue.assign($0) }
      )
    )

    #expect(sut.binding == false)
    sut.binding = true
    #expect(sut.binding == true, "@Binding behavior Changed! It was previously changing from the initial value.")
  }
}
