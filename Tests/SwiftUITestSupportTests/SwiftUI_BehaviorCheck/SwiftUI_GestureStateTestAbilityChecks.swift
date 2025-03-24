import Testing
import SwiftUI

private struct TestView: View {

  @GestureState
  var gestureState: Bool = false

  var body: some View { EmptyView() }
}

// ✅ @GestureState is Testable.
// Values cannot be changed by business logic, only from UI Gestures, thus no needs to be replaced

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_GestureStateTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_GestureStateTestAbilityChecks {

  @Test
  func Given_AGestureStateInAView_When_ValueIsRead_Then_TheValueIsCorrect() async {

    let sut = TestView()

    #expect(sut.gestureState == false, "@GestureState behavior Changed! It was previously testable")
  }
}
