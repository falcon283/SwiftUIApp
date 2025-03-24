#if os(visionOS)
import Testing
import SwiftUI

private struct TestView: View {

  @PhysicalMetric(from: .meters)
  var value = 1

  var body: some View { EmptyView() }
}

// ✅ @PhysicalMetric is Testable.
// Values cannot be changed by business logic, only from UI Gestures, thus no needs to be replaced

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_PhysicalMetricTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_PhysicalMetricTestAbilityChecks {

  @Test
  func Given_APhysicalMetricInAView_When_ValueIsRead_Then_TheValueIsCorrect() async {

    let sut = TestView()

    #expect(sut.value == 1360, "@PhysicalMetric behavior Changed!")
  }
}
#endif
