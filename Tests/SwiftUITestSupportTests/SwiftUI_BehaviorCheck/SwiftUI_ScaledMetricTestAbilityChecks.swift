import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @ScaledMetric
  var value = 20000

  var body: some View { EmptyView() }
}

// ❌ @ScaledMetric is not Testable.
// Values depends on the device specific settings.

extension SwiftUIBehaviour {
  @Suite
  @MainActor
  struct SwiftUI_ScaledMetricTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_ScaledMetricTestAbilityChecks {

#if os(watchOS)
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AScaledMetricInAView_When_ValueIsRead_Then_ValueIsNotCorrect() async {

    let sut = TestView()

    #expect(sut.value != 20000, "@ScaledMetric behavior Changed!")
  }
#else
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AScaledMetricInAView_When_ValueIsRead_Then_ValueIsNotCorrect() async {

    let sut = TestView()

    #expect(sut.value == 20000, "@ScaledMetric behavior Changed!")
  }
#endif
}
