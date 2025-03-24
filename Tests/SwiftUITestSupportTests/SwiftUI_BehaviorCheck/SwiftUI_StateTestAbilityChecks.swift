import Testing
import SwiftUI

private struct TestView: View {

  @State
  var value = 10

  var body: some View { EmptyView() }
}

// ❌ @State is not Testable

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_StateTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_StateTestAbilityChecks {

  @Test
  func Given_AStateInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() async {

    let sut = TestView()

    #expect(sut.value == 10)
    sut.value = 20
    #expect(sut.value == 10, "@State behavior Changed! It was previously not changing from the initial value.")
  }
}
