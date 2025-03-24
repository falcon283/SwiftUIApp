import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @ScaledMetric
  var value = 10

  var body: some View { EmptyView() }
}

// ✅ @ScaledMetric is Testable.
// Values cannot be changed by business logic, only from UI Gestures, thus no needs to be replaced

extension SwiftUIBehaviour {
  @Suite
  @MainActor
  struct SwiftUI_ScaledMetricTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_ScaledMetricTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AScaledMetricInAView_When_ValueIsRead_Then_ValueIsCorrect() async {

    let sut = TestView()

    #expect(sut.value == 10, "@ScaledMetric behavior Changed!")
  }
}
